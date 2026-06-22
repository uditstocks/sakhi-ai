"""
lang_config.py — Single source of truth for language support in Sakhi AI.

Every language the app exposes in its picker must have a complete entry here so
the whole pipeline (Whisper STT → LLM → Gemini → Google TTS) stays in the SAME
language end-to-end. Adding a language in one place previously caused mismatches
(e.g. Bengali text spoken by a Bengali voice but generated in Hindi). Keeping all
four dimensions in one table prevents that drift.

Each entry defines:
  - whisper:     language hint passed to faster-whisper for transcription
  - instruction: instruction appended to LLM / Gemini prompts
  - tts:         (google_language_code, google_voice_name) for Cloud TTS
"""

from dataclasses import dataclass

# Default language used whenever an unknown/unsupported code is requested.
DEFAULT_LANGUAGE = "hi"


@dataclass(frozen=True)
class LanguageProfile:
    """Full pipeline configuration for one supported language."""
    code: str
    whisper: str
    instruction: str
    tts_language: str
    tts_voice: str


# NOTE: every code here MUST match a value in the Flutter AppLanguage enum
# (frontend/lib/l10n/app_language.dart). Do not add a code to one side only.
LANGUAGES: dict[str, LanguageProfile] = {
    "hi": LanguageProfile("hi", "hi", "Answer in simple Hindi.", "hi-IN", "hi-IN-Wavenet-A"),
    "en": LanguageProfile("en", "en", "Answer in simple English.", "en-IN", "en-IN-Wavenet-A"),
    "mr": LanguageProfile("mr", "mr", "Answer in simple Marathi.", "mr-IN", "mr-IN-Wavenet-A"),
    "te": LanguageProfile("te", "te", "Answer in simple Telugu.", "te-IN", "te-IN-Standard-A"),
    "ta": LanguageProfile("ta", "ta", "Answer in simple Tamil.", "ta-IN", "ta-IN-Wavenet-A"),
    "bn": LanguageProfile("bn", "bn", "Answer in simple Bengali.", "bn-IN", "bn-IN-Wavenet-A"),
    "kn": LanguageProfile("kn", "kn", "Answer in simple Kannada.", "kn-IN", "kn-IN-Wavenet-A"),
}


def get_profile(language_code: str | None) -> LanguageProfile:
    """Returns the profile for the given code, falling back to the default."""
    if not language_code:
        return LANGUAGES[DEFAULT_LANGUAGE]
    return LANGUAGES.get(language_code.strip().lower(), LANGUAGES[DEFAULT_LANGUAGE])


def get_whisper_language(language_code: str | None) -> str:
    """Whisper transcription language hint for the given code."""
    return get_profile(language_code).whisper


def get_llm_instruction(language_code: str | None) -> str:
    """LLM/Gemini prompt instruction string for the given code."""
    return get_profile(language_code).instruction


def get_tts_voice(language_code: str | None) -> tuple[str, str]:
    """(google_language_code, google_voice_name) tuple for the given code."""
    profile = get_profile(language_code)
    return profile.tts_language, profile.tts_voice
