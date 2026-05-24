from faster_whisper import WhisperModel
import subprocess
import os

model = WhisperModel("tiny")
print("Whisper ready")

def convert_to_wav(input_path: str) -> str:
    output_path = input_path.replace(os.path.splitext(input_path)[1], "_converted.wav")
    subprocess.run([
        "ffmpeg", "-y", "-i", input_path,
        "-ar", "16000", "-ac", "1", output_path
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return output_path

def transcribe_audio(file_path: str) -> str:
    try:
        converted_path = convert_to_wav(file_path)
        segments, info = model.transcribe(converted_path, beam_size=5,language="hi")
        transcript = " ".join([segment.text for segment in segments])
        print(f"Transcribed: {transcript}")
        print(f"Detected language: {info.language}")
        return transcript.strip()
    except Exception as e:
        print(f"Whisper error: {e}")
        return ""