"""
llm_module.py — NVIDIA text LLM module for Sakhi AI.

Provides text generation and intent-aware conversational responses
using NVIDIA's Llama 3.1 8B model via OpenAI-compatible API.
Includes LangSmith tracing for monitoring and debugging.
"""

import os
import sys

# Add backend root to Python path for importing langsmith_setup
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

import langsmith_setup  # noqa: F401 — configure tracing before LangSmith client use
from dotenv import load_dotenv
from langsmith import traceable
from langsmith import wrappers
from openai import OpenAI

# Load environment variables from .env file in backend root directory
dotenv_path = os.path.join(_backend_root, ".env")
load_dotenv(dotenv_path)

# NVIDIA API configuration
NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"
TEXT_MODEL = "meta/llama-3.1-8b-instruct"

_trace_tags = ["sakhi-ai", "nvidia-nemotron"]
_project = langsmith_setup.LANGSMITH_PROJECT

# Singleton client pattern — create client only once to avoid re-initialization
_client: OpenAI | None = None


def _get_client() -> OpenAI:
    """
    Returns the singleton OpenAI client configured for NVIDIA API.
    Creates and wraps the client with LangSmith tracing on first call.
    Raises ValueError if LLM_KEY is missing from .env.
    """
    global _client
    if _client is not None:
        return _client

    api_key = os.getenv("LLM_KEY")
    if not api_key:
        raise ValueError(
            "LLM_KEY environment variable is missing or empty. "
            f"Please define it in your .env file at: {dotenv_path}"
        )

    raw_client = OpenAI(
        base_url=NVIDIA_BASE_URL,
        api_key=api_key,
    )
    # Wrap with LangSmith for tracing all LLM calls
    _client = wrappers.wrap_openai(
        raw_client,
        tracing_extra={
            "tags": _trace_tags,
            "metadata": {"integration": "nvidia-openai", "model": TEXT_MODEL},
        },
    )
    return _client


@traceable(
    name="generate_text",
    run_type="llm",
    project_name=_project,
    tags=_trace_tags,
)
def generate_text(prompt: str, temperature: float = 0.7) -> str:
    """
    Single-turn text generation via NVIDIA OpenAI-compatible API.

    Args:
        prompt: The user prompt to send to the LLM.
        temperature: Sampling temperature (0.0 = deterministic, 1.0 = creative). Default 0.7.

    Returns:
        The LLM's text response, stripped of whitespace. Empty string on failure.
    """
    response = _get_client().chat.completions.create(
        model=TEXT_MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=temperature,
    )
    content = response.choices[0].message.content
    if content:
        return content.strip()
    return ""


@traceable(
    name="ask_llm",
    run_type="chain",
    project_name=_project,
    tags=_trace_tags,
)
def ask_llm(query: str, context: str = "") -> str:
    """
    Sends a query to the LLM with optional RAG context.
    If context is provided, it's included as agricultural reference material.

    Args:
        query: The farmer's question.
        context: Optional context from ChromaDB documents to ground the response.

    Returns:
        The LLM's response text, or an error message on failure.
    """
    if context:
        prompt = f"""
You are Sakhi AI, an agricultural assistant for Indian farmers.

Use the given context to help answer the user's question. If the context doesn't cover the answer, use your general agricultural knowledge but note that it's from general knowledge.

CONTEXT:
{context}

QUESTION:
{query}
"""
    else:
        prompt = f"""
You are Sakhi AI, an agricultural assistant for Indian farmers.

QUESTION:
{query}
"""

    try:
        text = generate_text(prompt)
        if text:
            return text
        return "I could not generate a response. Please try again."
    except Exception as e:
        return f"Error communicating with LLM API: {e}"


# System prompts for each intent category — guide the LLM's response style
INTENT_SYSTEM_PROMPTS = {
    "price": """You are Sakhi AI. The farmer is asking about crop prices or when to sell.
Give a direct, simple answer about prices. Mention the current trend if context has it.
Keep it under 3 sentences. Speak like a trusted friend, not a report.""",

    "disease": """You are Sakhi AI. The farmer is asking about a crop disease or pest problem.
Name the disease if you can identify it. Give one simple remedy or action she can take today.
Keep it under 3 sentences. Use simple words, no scientific jargon.""",

    "scheme": """You are Sakhi AI. The farmer is asking about a government scheme or benefit.
Name the scheme, who is eligible, and what she needs to do to claim it.
Keep it under 4 sentences. Be specific and encouraging.""",

    "weather": """You are Sakhi AI. The farmer is asking about weather or when to plant/harvest.
Give practical farming advice based on the weather context.
Keep it under 3 sentences.""",

    "general": """You are Sakhi AI, an agricultural assistant for Indian farmers.
Answer the farming question simply and practically.
Keep it under 3 sentences. Speak like a trusted community advisor.""",
}


@traceable(
    name="ask_llm_with_intent",
    run_type="chain",
    project_name=_project,
    tags=_trace_tags,
)
def ask_llm_with_intent(
    query: str, context: str, intent: str, language: str = "hi"
) -> str:
    """
    Generates an intent-aware LLM response with language and context support.
    Selects the appropriate system prompt based on classified intent,
    includes RAG context, and formats the response in the requested language.

    Args:
        query: The farmer's question.
        context: RAG context from ChromaDB or live data (prices, weather).
        intent: The classified intent (price, disease, scheme, weather, general).
        language: Language code for the response (hi, te, mr, ta, en).

    Returns:
        The LLM's response in the requested language, or an error message.
    """
    # Select system prompt based on the classified intent
    system_prompt = INTENT_SYSTEM_PROMPTS.get(
        intent, INTENT_SYSTEM_PROMPTS["general"]
    )

    # Map language codes to instruction strings
    lang_instruction = {
        "hi": "Answer in simple Hindi.",
        "te": "Answer in simple Telugu.",
        "mr": "Answer in simple Marathi.",
        "ta": "Answer in simple Tamil.",
        "en": "Answer in simple English.",
    }.get(language, "Answer in simple Hindi.")

    prompt = f"""
{system_prompt}
{lang_instruction}

CONTEXT FROM ICAR DOCUMENTS:
{context if context else "No specific document found. Use general agricultural knowledge."}

FARMER'S QUESTION:
{query}
"""

    try:
        text = generate_text(
            prompt,
            langsmith_extra={"metadata": {"intent": intent, "language": language}},
        )
        if text:
            return text
        return "Mujhe maafi chahiye, main abhi jawab nahi de sakti. Dobara poochein."
    except Exception as e:
        return f"Error: {e}"
