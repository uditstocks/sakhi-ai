from faster_whisper import WhisperModel

model = WhisperModel("tiny")

def transcribe_audio(file_path):

    segments, info = model.transcribe(file_path)

    full_text = ""

    for segment in segments:
        full_text += segment.text

    return full_text