import os
from dotenv import load_dotenv
from google import genai

# Load .env relative to this file's directory
module_dir = os.path.dirname(os.path.abspath(__file__))
dotenv_path = os.path.join(module_dir, ".env")
load_dotenv(dotenv_path)

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise ValueError(f"GEMINI_API_KEY environment variable is missing. Check your .env file at {dotenv_path}")

client = genai.Client(api_key=api_key)

# Vision-only smoke test — text LLM is in llm_module.py (NVIDIA Nemotron).
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Hello"
)

print(response.text)