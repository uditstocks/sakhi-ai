"""
gemini_module.py — Google Gemini Vision module for Sakhi AI.

Handles leaf image analysis for crop disease diagnosis.
Uses Gemini 2.5 Flash model with LangSmith tracing integration.
Text LLM calls are handled separately in llm_module.py (NVIDIA Nemotron).
"""

import base64
import os
import sys

# Add backend root to Python path for importing langsmith_setup
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

import langsmith_setup  # noqa: F401
from dotenv import load_dotenv
from google import genai
from langsmith import traceable
from langsmith import wrappers

# Vision-only module — text LLM calls live in llm_module.py (NVIDIA Nemotron).

# Load environment variables from .env file in backend root directory
dotenv_path = os.path.join(_backend_root, ".env")
load_dotenv(dotenv_path)

# Validate and initialize Gemini API client
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise ValueError(
        "GEMINI_API_KEY environment variable is missing or empty. "
        f"Required for image analysis. Check your .env file at: {dotenv_path}"
    )

# Create Gemini client and wrap it with LangSmith tracing for monitoring
_gemini_client = genai.Client(api_key=api_key)
vision_client = wrappers.wrap_gemini(
    _gemini_client,
    tracing_extra={
        "tags": ["sakhi-ai", "gemini-vision"],
        "metadata": {"integration": "google-genai", "module": "gemini_module"},
    },
)
VISION_MODEL = "gemini-2.5-flash"
_project = langsmith_setup.LANGSMITH_PROJECT


@traceable(
    name="analyze_leaf_image",
    run_type="chain",
    project_name=_project,
    tags=["sakhi-ai", "gemini-vision"],
)
def analyze_leaf_image(image_path: str, language: str = "hi") -> str:
    """
    Analyzes a crop leaf image for disease diagnosis using Gemini Vision.

    Args:
        image_path: Path to the leaf image file (jpg, jpeg, png, or webp).
        language: Language code for the response (hi=Hindi, te=Telugu, mr=Marathi, ta=Tamil, en=English).

    Returns:
        A string with the diagnosis in simple language, or an error message if analysis fails.
    """
    try:
        # Map language codes to instruction strings for the prompt
        lang_instruction = {
            "hi": "Answer in simple Hindi.",
            "te": "Answer in simple Telugu.",
            "mr": "Answer in simple Marathi.",
            "ta": "Answer in simple Tamil.",
            "en": "Answer in simple English.",
        }.get(language, "Answer in simple Hindi.")

        # System prompt instructs Gemini to act as an agricultural diagnosis assistant
        prompt = f"""
You are Sakhi AI, an agricultural disease diagnosis assistant for Indian farmers.

Look at this leaf image carefully and:
1. Identify if there is any disease, pest damage, or nutrient deficiency
2. Name the disease or problem in simple terms
3. Give one immediate action the farmer can take today
4. Mention which fungicide, pesticide, or remedy to use with dosage if applicable

{lang_instruction}
Keep answer under 4 sentences. Use simple words, no scientific jargon.
If the image is not a plant or leaf, say "Kripya fasal ke patte ki photo bhejein."
"""

        # Read and base64-encode the image for the Gemini API
        with open(image_path, "rb") as f:
            image_bytes = f.read()

        encoded = base64.b64encode(image_bytes).decode("utf-8")

        # Determine MIME type from file extension
        ext = image_path.lower().split(".")[-1]
        mime_map = {
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "png": "image/png",
            "webp": "image/webp",
        }
        mime_type = mime_map.get(ext, "image/jpeg")

        # Send image + prompt to Gemini for analysis
        response = vision_client.models.generate_content(
            model=VISION_MODEL,
            contents=[
                {
                    "parts": [
                        {
                            "inline_data": {
                                "mime_type": mime_type,
                                "data": encoded,
                            }
                        },
                        {"text": prompt},
                    ]
                }
            ],
        )

        if response and response.text:
            return response.text
        return "Image analyse nahi ho saki. Dobara try karein."

    except Exception as e:
        print(f"Vision error: {e}")
        return f"Image analyse mein error aaya: {e}"
