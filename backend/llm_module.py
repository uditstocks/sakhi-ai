import os

from dotenv import load_dotenv
from openai import OpenAI

module_dir = os.path.dirname(os.path.abspath(__file__))
dotenv_path = os.path.join(module_dir, ".env")
load_dotenv(dotenv_path)

NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"
TEXT_MODEL = "nvidia/nemotron-3-super-120b-a12b"

_client: OpenAI | None = None


def _get_client() -> OpenAI:
    global _client
    if _client is not None:
        return _client

    api_key = os.getenv("LLM_KEY")
    if not api_key:
        raise ValueError(
            "LLM_KEY environment variable is missing or empty. "
            f"Please define it in your .env file at: {dotenv_path}"
        )

    _client = OpenAI(
        base_url=NVIDIA_BASE_URL,
        api_key=api_key,
    )
    return _client


def generate_text(prompt: str, temperature: float = 0.7) -> str:
    """Single-turn text generation via NVIDIA OpenAI-compatible API."""
    response = _get_client().chat.completions.create(
        model=TEXT_MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=temperature,
    )
    content = response.choices[0].message.content
    if content:
        return content.strip()
    return ""


def ask_llm(query: str, context: str = "") -> str:
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


def ask_llm_with_intent(
    query: str, context: str, intent: str, language: str = "hi"
) -> str:
    system_prompt = INTENT_SYSTEM_PROMPTS.get(
        intent, INTENT_SYSTEM_PROMPTS["general"]
    )

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
        text = generate_text(prompt)
        if text:
            return text
        return "Mujhe maafi chahiye, main abhi jawab nahi de sakti. Dobara poochein."
    except Exception as e:
        return f"Error: {e}"
