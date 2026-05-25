from fastapi import FastAPI, UploadFile, File, Body #    FastAPI framework, Handles API routes
from gemini_module import ask_gemini # custom function to call Google Gemini LLM
from whisper_module import transcribe_audio  #    converts speech → text using Whisper
from chromadb_module import search_documents #    Performs vector search (RAG system) using ChromaDB
from tts_module import text_to_speech
from fastapi.responses import Response
from langchain_module import classify_intent
from gemini_module import ask_gemini, ask_gemini_with_intent
from market_module import get_mandi_price
from weather_module import get_weather
from gemini_module import ask_gemini, ask_gemini_with_intent, analyze_leaf_image
from fastapi.middleware.cors import CORSMiddleware


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

#helper functions

def extract_crop_from_query(query: str) -> str:
    crops = {
        "wheat": "wheat", "gehoon": "wheat", "gehun": "wheat",
        "rice": "rice", "chawal": "rice", "dhan": "rice",
        "cotton": "cotton", "kapas": "cotton",
        "maize": "maize", "makka": "maize",
        "onion": "onion", "pyaaz": "onion",
        "potato": "potato", "aloo": "potato",
        "tomato": "tomato", "tamatar": "tomato",
    }
    query_lower = query.lower()
    for keyword, crop in crops.items():
        if keyword in query_lower:
            return crop
    return "wheat"  # default


def extract_location_from_query(query: str) -> str:
    cities = [
        "delhi", "mumbai", "pune", "lucknow", "patna",
        "jaipur", "bhopal", "hyderabad", "nagpur", "chandigarh",
        "varanasi", "agra", "kanpur", "indore", "nashik"
    ]
    query_lower = query.lower()
    for city in cities:
        if city in query_lower:
            return city.capitalize()
    return "Lucknow"  # default for UP farmers
# =========================
# CHAT ENDPOINT (FIXED)
# =========================
@app.post("/chat")
def chat(data: dict = Body(...)):
    try:
        query = data.get("query", "").strip()
        language = data.get("language", "hi")

        if not query:
            return {"error": "Query is empty"}

        intent = classify_intent(query)
        print(f"Intent: {intent}")

        # SOS — bypass everything
        if intent == "sos":
            return {
                "intent": "sos",
                "response": "EMERGENCY: Aapka SOS alert bheja ja raha hai. Aap safe rahein, madad aa rahi hai.",
                "action": "TRIGGER_SOS"
            }

        # Price — use live AgMarkNet data
        if intent == "price":
            crop = extract_crop_from_query(query)
            live_price = get_mandi_price(crop)
            context = live_price
            response = ask_gemini_with_intent(query, context, intent, language)
            return {"intent": intent, "response": response, "live_data": live_price}

        # Weather — use live OpenWeather data
        if intent == "weather":
            location = extract_location_from_query(query)
            live_weather = get_weather(location)
            context = live_weather
            response = ask_gemini_with_intent(query, context, intent, language)
            return {"intent": intent, "response": response, "live_data": live_weather}

        # Disease, scheme, general — use RAG
        context = get_rag_context(query)
        response = ask_gemini_with_intent(query, context, intent, language)
        return {"intent": intent, "response": response, "context_used": context}

    except Exception as e:
        print("CHAT ERROR:", str(e))
        return {"error": str(e)}


# =========================
# VOICE ENDPOINT (SAFE)
# =========================
@app.post("/voice")
async def voice_chat(file: UploadFile = File(...), language: str = "hi"):
    ext = os.path.splitext(file.filename)[1] or ".wav"
    file_path = f"uploads/{uuid.uuid4()}{ext}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    transcription = transcribe_audio(file_path)

    if not transcription:
        return {"error": "Could not transcribe audio"}

    intent = classify_intent(transcription)
    print(f"Intent: {intent}")

    # SOS — bypass everything, respond immediately
    if intent == "sos":
        sos_text = "Aapka SOS alert bheja ja raha hai. Aap safe rahein, madad aa rahi hai."
        audio_bytes = text_to_speech(sos_text, language_code=language)
        if audio_bytes:
            return Response(content=audio_bytes, media_type="audio/mpeg")
        return {"intent": "sos", "response": sos_text, "action": "TRIGGER_SOS"}

    # Price — live AgMarkNet data
    if intent == "price":
        crop = extract_crop_from_query(transcription)
        context = get_mandi_price(crop)
        response_text = ask_gemini_with_intent(transcription, context, intent, language)
        audio_bytes = text_to_speech(response_text, language_code=language)
        if audio_bytes:
            return Response(content=audio_bytes, media_type="audio/mpeg")
        return {"intent": intent, "transcription": transcription, "response": response_text}

    # Weather — live OpenWeather data
    if intent == "weather":
        location = extract_location_from_query(transcription)
        context = get_weather(location)
        response_text = ask_gemini_with_intent(transcription, context, intent, language)
        audio_bytes = text_to_speech(response_text, language_code=language)
        if audio_bytes:
            return Response(content=audio_bytes, media_type="audio/mpeg")
        return {"intent": intent, "transcription": transcription, "response": response_text}

    # Disease, scheme, general — RAG
    context = get_rag_context(transcription)
    response_text = ask_gemini_with_intent(transcription, context, intent, language)
    audio_bytes = text_to_speech(response_text, language_code=language)
    if audio_bytes:
        return Response(content=audio_bytes, media_type="audio/mpeg")

    return {
        "intent": intent,
        "transcription": transcription,
        "response": response_text
    }

#diagnosis endpoint 
@app.post("/diagnose")
async def diagnose_crop(file: UploadFile = File(...), language: str = "hi"):
    ext = os.path.splitext(file.filename)[1] or ".jpg"
    file_path = f"uploads/{uuid.uuid4()}{ext}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    diagnosis = analyze_leaf_image(file_path, language=language)

    # Convert diagnosis text to speech
    audio_bytes = text_to_speech(diagnosis, language_code=language)

    if audio_bytes:
        return Response(content=audio_bytes, media_type="audio/mpeg")

    return {
        "diagnosis": diagnosis,
        "language": language
    }
# =========================
# DEBUG RAG ENDPOINT
# =========================
@app.get("/rag-query") #Used to test vector search.
def rag_query(query: str):
    try:
        return search_documents(query) #Directly returns raw ChromaDB results
    except Exception as e:
        return {"error": str(e)}