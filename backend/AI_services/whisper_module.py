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

# Load the Whisper tiny model (smallest, fastest — suitable for Hindi speech)
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
    """
    output_path = input_path.replace(
        os.path.splitext(input_path)[1], "_converted.wav"
    )
    subprocess.run(
        [
            "ffmpeg", "-y", "-i", input_path,
            "-ar", "16000", "-ac", "1", output_path,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return output_path


@traceable(
    name="transcribe_audio",
    run_type="tool",
    project_name=_project,
    tags=["sakhi-ai", "whisper"],
)
def transcribe_audio(file_path: str) -> str:
    """
    Transcribes an audio file to text using faster-whisper.
    Converts to WAV first, then runs transcription with Hindi language hint.

    Args:
        file_path: Path to the audio file to transcribe.

    Returns:
        The transcribed text, or empty string on failure.
    """
    try:
        converted_path = convert_to_wav(file_path)
        segments, info = model.transcribe(
            converted_path,
            beam_size=5,
            language="hi",
            vad_filter=False,
        )
        transcript = " ".join([segment.text for segment in segments])
        print(f"Transcribed: {transcript}")
        print(f"Detected language: {info.language}")
        return transcript.strip()
    except Exception as e:
        print(f"Whisper error: {e}")
        return ""
