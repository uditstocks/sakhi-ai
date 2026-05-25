import base64
import os

from dotenv import load_dotenv
from google import genai

# Vision-only module — text LLM calls live in llm_module.py (NVIDIA Nemotron).

module_dir = os.path.dirname(os.path.abspath(__file__))
dotenv_path = os.path.join(module_dir, ".env")
load_dotenv(dotenv_path)

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise ValueError(
        "GEMINI_API_KEY environment variable is missing or empty. "
        f"Required for image analysis. Check your .env file at: {dotenv_path}"
    )

vision_client = genai.Client(api_key=api_key)
VISION_MODEL = "gemini-2.5-flash"


def analyze_leaf_image(image_path: str, language: str = "hi") -> str:
    try:
        lang_instruction = {
            "hi": "Answer in simple Hindi.",
            "te": "Answer in simple Telugu.",
            "mr": "Answer in simple Marathi.",
            "ta": "Answer in simple Tamil.",
            "en": "Answer in simple English.",
        }.get(language, "Answer in simple Hindi.")

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

        with open(image_path, "rb") as f:
            image_bytes = f.read()

        encoded = base64.b64encode(image_bytes).decode("utf-8")

        ext = image_path.lower().split(".")[-1]
        mime_map = {
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "png": "image/png",
            "webp": "image/webp",
        }
        mime_type = mime_map.get(ext, "image/jpeg")

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
