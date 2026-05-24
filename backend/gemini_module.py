import os
from dotenv import load_dotenv
from google import genai

# Load .env relative to this file's directory to ensure it is found regardless of where uvicorn is started
module_dir = os.path.dirname(os.path.abspath(__file__))
dotenv_path = os.path.join(module_dir, ".env")
load_dotenv(dotenv_path)

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise ValueError(
        "GEMINI_API_KEY environment variable is missing or empty. "
        f"Please check that GEMINI_API_KEY is defined in your .env file at: {dotenv_path}"
    )

# Instantiate the client with the validated API key
client = genai.Client(api_key=api_key)

# Use the latest free-tier model 'gemini-2.5-flash'
MODEL = "gemini-2.5-flash"

def ask_gemini(query: str, context: str = ""):
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
        response = client.models.generate_content(
            model=MODEL,
            contents=prompt
        )
        if response and response.text:
            return response.text
        return "I could not generate a response. Please try again."
    except Exception as e:
        return f"Error communicating with Gemini API: {e}"
    
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
Keep it under 3 sentences. Speak like a trusted community advisor."""
}

def ask_gemini_with_intent(query: str, context: str, intent: str, language: str = "hi") -> str:
    system_prompt = INTENT_SYSTEM_PROMPTS.get(intent, INTENT_SYSTEM_PROMPTS["general"])
    
    lang_instruction = {
        "hi": "Answer in simple Hindi.",
        "te": "Answer in simple Telugu.",
        "mr": "Answer in simple Marathi.",
        "ta": "Answer in simple Tamil.",
        "en": "Answer in simple English."
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
        response = client.models.generate_content(
            model=MODEL,
            contents=prompt
        )
        if response and response.text:
            return response.text
        return "Mujhe maafi chahiye, main abhi jawab nahi de sakti. Dobara poochein."
    except Exception as e:
        return f"Error: {e}"