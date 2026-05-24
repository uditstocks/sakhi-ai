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