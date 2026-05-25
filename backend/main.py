from fastapi import FastAPI, UploadFile, File, Body
from fastapi.responses import Response, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import shutil
import os
import uuid

# ── Import your modules ────────────────────────────────────────────
from gemini_module import ask_gemini, ask_gemini_with_intent, analyze_leaf_image
from whisper_module import transcribe_audio
from chromadb_module import search_documents
from tts_module import text_to_speech
from langchain_module import classify_intent
from market_module import get_mandi_price
from weather_module import get_weather

# ── App MUST be created before add_middleware ──────────────────────
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs("uploads", exist_ok=True)


# ══════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ══════════════════════════════════════════════════════════════════

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
    return "wheat"


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
    return "Lucknow"


# ══════════════════════════════════════════════════════════════════
# HEALTH CHECK
# ══════════════════════════════════════════════════════════════════

@app.get("/")
def root():
    return {"message": "Sakhi AI Backend Running"}


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "Sakhi AI"}


# ══════════════════════════════════════════════════════════════════
# CHAT ENDPOINT — text in, text out
# ══════════════════════════════════════════════════════════════════

@app.post("/chat")
def chat(data: dict = Body(...)):
    try:
        query = data.get("query", "").strip()
        language = data.get("language", "hi")

        if not query:
            return {"error": "Query is empty"}

        intent = classify_intent(query)
        print(f"Intent: {intent}")

        if intent == "sos":
            return {
                "intent": "sos",
                "response": "EMERGENCY: Aapka SOS alert bheja ja raha hai. Aap safe rahein, madad aa rahi hai.",
                "action": "TRIGGER_SOS"
            }

        if intent == "price":
            crop = extract_crop_from_query(query)
            live_price = get_mandi_price(crop)
            response = ask_gemini_with_intent(query, live_price, intent, language)
            return {"intent": intent, "response": response, "live_data": live_price}

        if intent == "weather":
            location = extract_location_from_query(query)
            live_weather = get_weather(location)
            response = ask_gemini_with_intent(query, live_weather, intent, language)
            return {"intent": intent, "response": response, "live_data": live_weather}

        context = get_rag_context(query)
        response = ask_gemini_with_intent(query, context, intent, language)
        return {"intent": intent, "response": response}

    except Exception as e:
        print("CHAT ERROR:", str(e))
        return {"error": str(e)}


# ══════════════════════════════════════════════════════════════════
# VOICE ENDPOINT — audio file in, mp3 audio out
# ══════════════════════════════════════════════════════════════════

@app.post("/voice")
async def voice_chat(file: UploadFile = File(...), language: str = "hi"):
    ext = os.path.splitext(file.filename)[1] or ".m4a"
    file_path = f"uploads/{uuid.uuid4()}{ext}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    transcription = transcribe_audio(file_path)
    print(f"Transcription: {transcription}")

    if not transcription:
        return JSONResponse(
            status_code=422,
            content={"error": "Could not transcribe audio"},
        )

    intent = classify_intent(transcription)
    print(f"Intent: {intent}")

    if intent == "sos":
        sos_text = "Aapka SOS alert bheja ja raha hai. Aap safe rahein, madad aa rahi hai."
        audio_bytes = text_to_speech(sos_text, language_code=language)
        if audio_bytes:
            return Response(content=audio_bytes, media_type="audio/mpeg")
        return {"intent": "sos", "transcription": transcription, "response": sos_text, "action": "TRIGGER_SOS"}

    if intent == "price":
        crop = extract_crop_from_query(transcription)
        context = get_mandi_price(crop)
        response_text = ask_gemini_with_intent(transcription, context, intent, language)
        audio_bytes = text_to_speech(response_text, language_code=language)
        if audio_bytes:
            return Response(content=audio_bytes, media_type="audio/mpeg")
        return {"intent": intent, "transcription": transcription, "response": response_text}

    if intent == "weather":
        location = extract_location_from_query(transcription)
        context = get_weather(location)
        response_text = ask_gemini_with_intent(transcription, context, intent, language)
        audio_bytes = text_to_speech(response_text, language_code=language)
        if audio_bytes:
            return Response(content=audio_bytes, media_type="audio/mpeg")
        return {"intent": intent, "transcription": transcription, "response": response_text}

    # disease / scheme / general — RAG
    context = get_rag_context(transcription)
    response_text = ask_gemini_with_intent(transcription, context, intent, language)
    audio_bytes = text_to_speech(response_text, language_code=language)
    if audio_bytes:
        return Response(content=audio_bytes, media_type="audio/mpeg")
    return {"intent": intent, "transcription": transcription, "response": response_text}


# ══════════════════════════════════════════════════════════════════
# DIAGNOSE ENDPOINT — leaf image in, mp3 audio out
# ══════════════════════════════════════════════════════════════════

@app.post("/diagnose")
async def diagnose_crop(file: UploadFile = File(...), language: str = "hi"):
    ext = os.path.splitext(file.filename)[1] or ".jpg"
    file_path = f"uploads/{uuid.uuid4()}{ext}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    diagnosis = analyze_leaf_image(file_path, language=language)
    audio_bytes = text_to_speech(diagnosis, language_code=language)

    if audio_bytes:
        return Response(content=audio_bytes, media_type="audio/mpeg")
    return {"diagnosis": diagnosis, "language": language}


# ══════════════════════════════════════════════════════════════════
# MANDI PRICES
# ══════════════════════════════════════════════════════════════════

@app.get("/mandi")
def mandi_prices(crop: str = "wheat", state: str = "UP"):
    try:
        price_data = get_mandi_price(crop)
        return {"prices": [{"crop": crop, "state": state, "data": price_data}]}
    except Exception as e:
        return {"prices": [], "error": str(e)}


# ══════════════════════════════════════════════════════════════════
# GOVERNMENT SCHEMES
# ══════════════════════════════════════════════════════════════════

@app.get("/schemes")
def govt_schemes(state: str = "UP"):
    schemes = [
        {
            "name": "PM-KISAN",
            "benefit": "Rs.6,000 per year direct to account",
            "eligibility": "All small and marginal farmers",
            "how_to_apply": "pmkisan.gov.in ya Common Service Centre"
        },
        {
            "name": "PMFBY - Fasal Bima",
            "benefit": "Crop insurance against natural disasters",
            "eligibility": "All farmers with crop loan",
            "how_to_apply": "Nearest bank ya insurance company"
        },
        {
            "name": "Kisan Credit Card",
            "benefit": "Low interest crop loan up to Rs.3 lakh",
            "eligibility": "All farmers",
            "how_to_apply": "Nearest bank branch"
        },
        {
            "name": "PM Fasal Bima Yojana",
            "benefit": "Insurance for crop loss due to weather",
            "eligibility": "All farmers growing notified crops",
            "how_to_apply": "pmfby.gov.in"
        }
    ]
    return {"schemes": schemes, "state": state}


# ══════════════════════════════════════════════════════════════════
# SOS ALERT
# ══════════════════════════════════════════════════════════════════

@app.post("/sos")
def sos_alert(data: dict = Body(...)):
    lat = data.get("latitude")
    lng = data.get("longitude")
    message = data.get("message", "SOS - Madad chahiye!")
    print(f"SOS RECEIVED: lat={lat}, lng={lng}, msg={message}")
    # TODO: WhatsApp Cloud API call here
    return {
        "status": "received",
        "message": "SOS alert registered",
        "location": {"lat": lat, "lng": lng}
    }


# ══════════════════════════════════════════════════════════════════
# SYNC STATUS
# ══════════════════════════════════════════════════════════════════

@app.get("/sync-status")
def sync_status():
    return {
        "last_sync_ago": "Just now",
        "status": "online",
        "cached_schemes": 4,
        "cached_prices": True
    }


# ══════════════════════════════════════════════════════════════════
# DEBUG — RAG QUERY
# ══════════════════════════════════════════════════════════════════

@app.get("/rag-query")
def rag_query(query: str):
    try:
        return search_documents(query)
    except Exception as e:
        return {"error": str(e)}