from fastapi import FastAPI, UploadFile, File, Body
from gemini_module import ask_gemini
from whisper_module import transcribe_audio
from chromadb_module import search_documents

import shutil
import os
import uuid

app = FastAPI()

# =========================
# INIT
# =========================
os.makedirs("uploads", exist_ok=True)


# =========================
# HEALTH CHECK
# =========================
@app.get("/")
def home():
    return {"message": "Sakhi AI Backend Running"}


# =========================
# RAG CONTEXT (SAFE VERSION)
# =========================
def get_rag_context(query: str) -> str:
    try:
        results = search_documents(query)

        if not results:
            return ""

        docs = results.get("documents")

        if not docs or not isinstance(docs, list):
            return ""

        first_batch = docs[0] if len(docs) > 0 else []

        if not first_batch:
            return ""

        return "\n\n".join([d for d in first_batch if d])

    except Exception as e:
        print("RAG ERROR:", str(e))
        return ""


# =========================
# CHAT ENDPOINT (FIXED)
# =========================
@app.post("/chat")
def chat(data: dict = Body(...)):
    try:
        query = data.get("query", "").strip()

        if not query:
            return {"error": "Query is empty"}

        print("QUERY:", query)

        context = get_rag_context(query)

        if not context:
            context = "No relevant agricultural data found."

        response = ask_gemini(query, context)

        return {
            "response": response,
            "context_used": context
        }

    except Exception as e:
        print("CHAT ERROR:", str(e))
        return {"error": str(e)}


# =========================
# VOICE ENDPOINT (SAFE)
# =========================
@app.post("/voice")
async def voice_chat(file: UploadFile = File(...)):
    try:
        ext = os.path.splitext(file.filename)[1] or ".wav"
        file_path = f"uploads/{uuid.uuid4()}{ext}"

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        transcription = transcribe_audio(file_path)

        if not transcription:
            return {"error": "Could not transcribe audio"}

        context = get_rag_context(transcription)

        if not context:
            context = "No relevant agricultural data found."

        response = ask_gemini(transcription, context)

        return {
            "transcription": transcription,
            "response": response,
            "context_used": context
        }

    except Exception as e:
        print("VOICE ERROR:", str(e))
        return {"error": str(e)}


# =========================
# DEBUG RAG ENDPOINT
# =========================
@app.get("/rag-query")
def rag_query(query: str):
    try:
        return search_documents(query)
    except Exception as e:
        return {"error": str(e)}