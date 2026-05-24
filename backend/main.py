from fastapi import FastAPI, UploadFile, File, Body #    FastAPI framework, Handles API routes
from gemini_module import ask_gemini # custom function to call Google Gemini LLM
from whisper_module import transcribe_audio  #    converts speech → text using Whisper
from chromadb_module import search_documents #    Performs vector search (RAG system) using ChromaDB


#    File handling ,    UUID = unique filenames for uploads
import shutil
import os
import uuid

app = FastAPI() #Creates backend server

# =========================
# INIT
# =========================
os.makedirs("uploads", exist_ok=True)  #    Creates folder to store audio files


# =========================
# HEALTH CHECK (checks if backend is running)
# =========================
@app.get("/")
def home():
    return {"message": "Sakhi AI Backend Running"}


# =========================
# RAG CONTEXT (SAFE VERSION)
# =========================
def get_rag_context(query: str) -> str: #This function gets relevant knowledge from database
    try:
        results = search_documents(query) #    Queries ChromaDB,     Returns similar agricultural docs

        if not results:
            return ""  #Prevents crashes if nothing found

        docs = results.get("documents") #ChromaDB usually returns: JSON {"documents": [[doc1, doc2, doc3]]}

        if not docs or not isinstance(docs, list):
            return ""

        first_batch = docs[0] if len(docs) > 0 else []

        if not first_batch:
            return ""

        return "\n\n".join([d for d in first_batch if d])

    except Exception as e: #Prevents backend crash if vector DB fails
        print("RAG ERROR:", str(e))
        return ""


# =========================
# CHAT ENDPOINT (FIXED)
# =========================
@app.post("/chat") #This handles normal text queries.
def chat(data: dict = Body(...)):
    try:
        query = data.get("query", "").strip() #get input 

        if not query:
            return {"error": "Query is empty"} #validate input

        print("QUERY:", query) #print for debugging

        context = get_rag_context(query) #get RAG context

        if not context:
            context = "No relevant agricultural data found."  #Prevents Gemini from getting empty context

        response = ask_gemini(query, context) #Send to Gemini

        return {
            "response": response,   #return response
            "context_used": context
        }

    except Exception as e:
        print("CHAT ERROR:", str(e))
        return {"error": str(e)}


# =========================
# VOICE ENDPOINT (SAFE)
# =========================
@app.post("/voice") #Handles audio input.
async def voice_chat(file: UploadFile = File(...)):
    try:
        ext = os.path.splitext(file.filename)[1] or ".wav" #Save audio file,     Generates unique filename * Prevents overwrite
        file_path = f"uploads/{uuid.uuid4()}{ext}"

        with open(file_path, "wb") as buffer:  #Saves uploaded audio locally
            shutil.copyfileobj(file.file, buffer)

        transcription = transcribe_audio(file_path) #Whisper converts audio → text

        if not transcription:
            return {"error": "Could not transcribe audio"}

        context = get_rag_context(transcription) #RAG search

        if not context:
            context = "No relevant agricultural data found."

        response = ask_gemini(transcription, context) #gemini response

        return {
            "transcription": transcription, #return full pipeline result
            "response": response,
            "context_used": context
        }

    except Exception as e:
        print("VOICE ERROR:", str(e))
        return {"error": str(e)}


# =========================
# DEBUG RAG ENDPOINT
# =========================
@app.get("/rag-query") #Used to test vector search.
def rag_query(query: str):
    try:
        return search_documents(query) #Directly returns raw ChromaDB results
    except Exception as e:
        return {"error": str(e)}