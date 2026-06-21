"""
whisper_module.py — Speech-to-text module for Sakhi AI.

Uses faster-whisper (tiny model) to transcribe farmer voice recordings
into text. Converts audio to WAV format before transcription.
Includes LangSmith tracing for monitoring.
"""

import os
import subprocess
import sys

# Add backend root to Python path for importing langsmith_setup
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

import langsmith_setup  # noqa: F401
from faster_whisper import WhisperModel
from langsmith import traceable

from lang_config import get_whisper_language

# Load the Whisper tiny model (smallest, fastest, multilingual — fits Indian languages)
model = WhisperModel("tiny")
print("Whisper ready")

_project = langsmith_setup.LANGSMITH_PROJECT


def convert_to_wav(input_path: str) -> str:
    """
    Converts an audio file to 16kHz mono WAV format using ffmpeg.
    Required because faster-whisper expects WAV input for best results.

    Args:
        input_path: Path to the source audio file (m4a, mp3, etc.).

    Returns:
        Path to the converted WAV file.

    Raises:
        RuntimeError: If ffmpeg is missing or the conversion fails.
    """
    # Build the output path from the real stem so a substring match inside the
    # path can never corrupt it (str.replace would replace every occurrence).
    base, _ = os.path.splitext(input_path)
    output_path = f"{base}_converted.wav"

    try:
        subprocess.run(
            [
                "ffmpeg", "-y", "-i", input_path,
                "-ar", "16000", "-ac", "1", output_path,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            check=True,
        )
    except FileNotFoundError as exc:
        raise RuntimeError(
            "ffmpeg not found on PATH — required to decode uploaded audio."
        ) from exc
    except subprocess.CalledProcessError as exc:
        stderr = (exc.stderr or b"").decode("utf-8", errors="replace").strip()
        raise RuntimeError(f"ffmpeg conversion failed: {stderr}") from exc

    return output_path


@traceable(
    name="transcribe_audio",
    run_type="tool",
    project_name=_project,
    tags=["sakhi-ai", "whisper"],
)
def transcribe_audio(file_path: str, language: str = "hi") -> str:
    """
    Transcribes an audio file to text using faster-whisper.
    Converts to WAV first, then runs transcription with the speaker's language hint.

    Args:
        file_path: Path to the audio file to transcribe.
        language: Language code of the speaker (hi, en, mr, te, ta, bn, kn).
            Determines the Whisper language hint so non-Hindi speech is not
            mis-transcribed as Hindi.

    Returns:
        The transcribed text, or empty string on failure.
    """
    try:
        converted_path = convert_to_wav(file_path)
        segments, info = model.transcribe(
            converted_path,
            beam_size=5,
            language=get_whisper_language(language),
            vad_filter=False,
        )
        transcript = " ".join([segment.text for segment in segments])
        print(f"Transcribed: {transcript}")
        print(f"Detected language: {info.language}")
        return transcript.strip()
    except Exception as e:
        print(f"Whisper error: {e}")
        return ""
