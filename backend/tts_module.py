from google.cloud.texttospeech import TextToSpeechClient, SynthesisInput, VoiceSelectionParams, AudioConfig, AudioEncoding, SsmlVoiceGender
import os
from dotenv import load_dotenv

# Load .env relative to this file's directory
module_dir = os.path.dirname(os.path.abspath(__file__))
dotenv_path = os.path.join(module_dir, ".env")
load_dotenv(dotenv_path)

# Resolve relative credentials path to absolute path
creds = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
if creds and not os.path.isabs(creds):
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.path.join(module_dir, creds)

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