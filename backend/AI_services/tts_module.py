"""
tts_module.py — Text-to-Speech module for Sakhi AI.

Converts text responses to MP3 audio using Google Cloud Text-to-Speech API.
Supports multiple Indian languages (Hindi, Telugu, Marathi, Tamil, Kannada, Bengali, English).
"""

from google.cloud.texttospeech import TextToSpeechClient, SynthesisInput, VoiceSelectionParams, AudioConfig, AudioEncoding, SsmlVoiceGender
import os
import sys
from dotenv import load_dotenv

# Add backend root to Python path
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

# Load .env from backend root directory
dotenv_path = os.path.join(_backend_root, ".env")
load_dotenv(dotenv_path)

# Resolve relative credentials path to absolute path for Google Cloud auth
creds = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
if creds and not os.path.isabs(creds):
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.path.join(_backend_root, creds)

# Maps language codes to (language_code, voice_name) tuples for Google TTS
LANGUAGE_VOICE_MAP = {
    "hi": ("hi-IN", "hi-IN-Wavenet-A"),
    "te": ("te-IN", "te-IN-Standard-A"),
    "mr": ("mr-IN", "mr-IN-Wavenet-A"),
    "ta": ("ta-IN", "ta-IN-Wavenet-A"),
    "kn": ("kn-IN", "kn-IN-Wavenet-A"),
    "bn": ("bn-IN", "bn-IN-Wavenet-A"),
    "en": ("en-IN", "en-IN-Wavenet-A"),
}


def text_to_speech(text: str, language_code: str = "hi") -> bytes:
    """
    Converts text to MP3 audio using Google Cloud Text-to-Speech.

    Args:
        text: The text to synthesize into speech.
        language_code: Language code for voice selection (hi, te, mr, ta, kn, bn, en).

    Returns:
        MP3 audio bytes, or None if synthesis fails.
    """
    try:
        client = TextToSpeechClient()
        lang, voice_name = LANGUAGE_VOICE_MAP.get(language_code, LANGUAGE_VOICE_MAP["hi"])

        response = client.synthesize_speech(
            input=SynthesisInput(text=text),
            voice=VoiceSelectionParams(
                language_code=lang,
                name=voice_name,
                ssml_gender=SsmlVoiceGender.FEMALE
            ),
            audio_config=AudioConfig(audio_encoding=AudioEncoding.MP3)
        )
        return response.audio_content

    except Exception as e:
        print(f"TTS error: {e}")
        return None