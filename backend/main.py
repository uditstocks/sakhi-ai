
from fastapi import FastAPI, UploadFile, File, Form, Body
from gemini_module import ask_gemini
from whisper_module import transcribe_audio
from chromadb_module import search_documents

import shutil
import os
import uuid

os.makedirs("uploads", exist_ok=True)

app = FastAPI()

@app.get("/")
def home():

    return {
        "message": "Sakhi AI Backend Running"
    }

def get_rag_context(query: str) -> str:
    try:
        results = search_documents(query)

        if results and results.get("documents"):
            return " ".join(results["documents"][0])

    except Exception as e:
        print(f"RAG error: {e}")

    return ""

from fastapi import Body

@app.post("/chat")
def chat(data: dict = Body(...)):
    query = data["query"]

    context = get_rag_context(query)
    response = ask_gemini(query, context=context)

    return {
        "response": response,
        "context_used": context
    }

@app.post("/voice")
async def voice_chat(file: UploadFile = File(...)):
    ext = os.path.splitext(file.filename)[1] or ".wav"
    file_path = f"uploads/{uuid.uuid4()}{ext}"
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    transcription = transcribe_audio(file_path)
    
    if not transcription:
        return {"error": "Could not transcribe audio"}
    
    context = get_rag_context(transcription)
    response = ask_gemini(transcription, context=context)
    
    return {
        "transcription": transcription,
        "response": response,
        "context_used": context
    }

@app.get("/rag-query")
def rag_query(query: str):

    results = search_documents(query)

    return results