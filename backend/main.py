"""
main.py — FastAPI entry point for Sakhi AI backend.

Defines all HTTP endpoints: /chat, /voice, /diagnose, /mandi, /schemes, /sos, etc.
Orchestrates the AI pipeline: intent classification → RAG search → LLM response → TTS.
"""

import langsmith_setup  # noqa: F401 — load LANGSMITH_* before traced imports

from fastapi import FastAPI, UploadFile, File, Body
from fastapi.responses import Response, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import shutil
import os
import uuid

from langsmith import traceable

# ── Import your modules ────────────────────────────────────────────
from AI_services.gemini_module import analyze_leaf_image
from nlp.llm_module import ask_llm_with_intent
from AI_services.whisper_module import transcribe_audio
from chromadb_module import search_documents
from AI_services.tts_module import text_to_speech
from nlp.langchain_module import classify_intent
from external_APIs.market_module import get_mandi_price
from external_APIs.weather_module import get_weather

# ── App MUST be created before add_middleware ──────────────────────
# Initialize the FastAPI application instance
app = FastAPI()

# CORS origins are configurable via the CORS_ALLOW_ORIGINS env var
# (comma-separated). Default "*" suits local dev and native apps (which send
# no Origin header). The wildcard + credentials combination is invalid per the
# CORS spec and is rejected by browsers, so credentials are only enabled when
# an explicit origin allow-list is provided.
_origins_env = os.getenv("CORS_ALLOW_ORIGINS", "*").strip()
_allow_origins = [o.strip() for o in _origins_env.split(",") if o.strip()]
_allow_all = _allow_origins == ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_allow_origins,
    allow_credentials=not _allow_all,
    allow_methods=["*"],
    allow_headers=["*"],
    # Custom headers the Flutter client reads off binary (audio) responses.
    expose_headers=["X-Sakhi-Intent", "X-Sakhi-Action"],
)

# Directory for uploaded audio/image files
os.makedirs("uploads", exist_ok=True)

_LANGSMITH_PROJECT = langsmith_setup.LANGSMITH_PROJECT
_TRACE_TAGS = ["sakhi-ai"]


# ══════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ══════════════════════════════════════════════════════════════════

@traceable(
    name="sakhi_rag_search",
    run_type="retriever",
    project_name=_LANGSMITH_PROJECT,
    tags=_TRACE_TAGS,
)
def get_rag_context(query: str) -> str:
    """
    Retrieves relevant agricultural documents from ChromaDB for the given query.
    Returns a concatenated string of top matching documents, or empty string if none found.
    """
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
    """
    Extracts the crop name from the user's query by matching against known crop keywords.
    Maps Hindi/English crop names to a canonical English name. Defaults to 'wheat'.
    """
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
    """
    Extracts a city/location name from the user's query by matching against known Indian cities.
    Returns the capitalized city name. Defaults to 'Lucknow'.
    """
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
    """Root endpoint — confirms the server is running."""
    return {"message": "Sakhi AI Backend Running"}


@app.get("/health")
def health_check():
    """
    Health check endpoint — returns service status and LangSmith configuration.
    Used by monitoring systems to verify the backend is operational.
    """
    return {
        "status": "ok",
        "service": "Sakhi AI",
        "langsmith_tracing": langsmith_setup.LANGSMITH_TRACING_ENABLED,
        "langsmith_project": langsmith_setup.LANGSMITH_PROJECT,
    }


# ══════════════════════════════════════════════════════════════════
# CHAT ENDPOINT — text in, text out
# ══════════════════════════════════════════════════════════════════

@traceable(
    name="sakhi_chat",
    run_type="chain",
    project_name=_LANGSMITH_PROJECT,
    tags=_TRACE_TAGS,
)
def process_chat(query: str, language: str) -> dict:
    """
    Processes a text chat query through the full AI pipeline:
    1. Classify user intent (price, disease, scheme, weather, sos, general)
    2. Fetch relevant context (RAG docs, live prices, or weather)
    3. Generate LLM response with context
    Returns a dict with intent, response text, and optional live data.
    """
    intent = classify_intent(query)
    print(f"Intent: {intent}")

    # SOS intent — return emergency response immediately
    if intent == "sos":
        return {
            "intent": "sos",
            "response": "EMERGENCY: Aapka SOS alert bheja ja raha hai. Aap safe rahein, madad aa rahi hai.",
            "action": "TRIGGER_SOS",
        }

    # Price intent — fetch live mandi prices and generate response
    if intent == "price":
        crop = extract_crop_from_query(query)
        live_price = get_mandi_price(crop)
        response = ask_llm_with_intent(query, live_price, intent, language)
        return {"intent": intent, "response": response, "live_data": live_price}

    # Weather intent — fetch live weather data and generate response
    if intent == "weather":
        location = extract_location_from_query(query)
        live_weather = get_weather(location)
        response = ask_llm_with_intent(query, live_weather, intent, language)
        return {"intent": intent, "response": response, "live_data": live_weather}

    # Default: use RAG context from ChromaDB for agricultural Q&A
    context = get_rag_context(query)
    response = ask_llm_with_intent(query, context, intent, language)
    return {"intent": intent, "response": response}


@app.post("/chat")
def chat(data: dict = Body(...)):
    """
    POST /chat — accepts JSON with 'query' (text) and optional 'language' code.
    Returns AI-generated text response based on classified intent.
    """
    try:
        query = data.get("query", "").strip()
        language = data.get("language", "hi")

        if not query:
            return {"error": "Query is empty"}

        return process_chat(
            query,
            language,
            langsmith_extra={"metadata": {"language": language}},
        )

    except Exception as e:
        print("CHAT ERROR:", str(e))
        return {"error": str(e)}


# ══════════════════════════════════════════════════════════════════
# VOICE ENDPOINT — audio file in, mp3 audio out
# ══════════════════════════════════════════════════════════════════

@traceable(
    name="sakhi_voice",
    run_type="chain",
    project_name=_LANGSMITH_PROJECT,
    tags=_TRACE_TAGS,
)
def process_voice(transcription: str, language: str) -> dict:
    """
    Processes a transcribed voice query through the AI pipeline.
    Same logic as process_chat but operates on already-transcribed text.
    Returns a dict with intent, transcription, response text, and optional action.
    """
    intent = classify_intent(transcription)
    print(f"Intent: {intent}")

    # SOS intent — return emergency response immediately
    if intent == "sos":
        sos_text = "Aapka SOS alert bheja ja raha hai. Aap safe rahein, madad aa rahi hai."
        return {
            "intent": intent,
            "transcription": transcription,
            "response": sos_text,
            "action": "TRIGGER_SOS",
        }

    # Price intent — fetch live mandi prices
    if intent == "price":
        crop = extract_crop_from_query(transcription)
        context = get_mandi_price(crop)
        response_text = ask_llm_with_intent(transcription, context, intent, language)
        return {
            "intent": intent,
            "transcription": transcription,
            "response": response_text,
        }

    # Weather intent — fetch live weather data
    if intent == "weather":
        location = extract_location_from_query(transcription)
        context = get_weather(location)
        response_text = ask_llm_with_intent(transcription, context, intent, language)
        return {
            "intent": intent,
            "transcription": transcription,
            "response": response_text,
        }

    # Default: use RAG context from ChromaDB
    context = get_rag_context(transcription)
    response_text = ask_llm_with_intent(transcription, context, intent, language)
    return {
        "intent": intent,
        "transcription": transcription,
        "response": response_text,
    }


def _voice_audio_response(payload: dict, language: str):
    """
    Converts the voice response payload into an MP3 audio Response.

    The classified intent and any action (e.g. TRIGGER_SOS) are returned in
    response headers so the client can react — for example, opening the SOS
    screen — even though the body is binary audio. Header values are ASCII-only
    (intent/action codes), so no encoding is required.

    If TTS fails, falls back to returning the JSON payload directly so the
    client still receives the text response and any action.
    """
    response_text = payload.get("response", "")
    audio_bytes = text_to_speech(response_text, language_code=language)

    if audio_bytes:
        headers = {"X-Sakhi-Intent": str(payload.get("intent", ""))}
        action = payload.get("action")
        if action:
            headers["X-Sakhi-Action"] = str(action)
        return Response(
            content=audio_bytes,
            media_type="audio/mpeg",
            headers=headers,
        )

    # TTS unavailable — return JSON so the client keeps the text and the action.
    return JSONResponse(content=payload)


@app.post("/voice")
async def voice_chat(file: UploadFile = File(...), language: str = "hi"):
    """
    POST /voice — accepts an audio file upload (m4a, wav, etc.) and optional language code.
    Transcribes audio → classifies intent → generates response → converts to MP3 audio.
    Returns an MP3 audio response or JSON fallback.
    """
    ext = os.path.splitext(file.filename)[1] or ".m4a"
    file_path = f"uploads/{uuid.uuid4()}{ext}"

    # Save uploaded audio file to disk
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Transcribe audio using Whisper, hinting the speaker's selected language
    transcription = transcribe_audio(file_path, language=language)
    print(f"Transcription: {transcription}")

    if not transcription:
        return JSONResponse(
            status_code=422,
            content={"error": "Could not transcribe audio"},
        )

    # Process transcription through AI pipeline and convert to audio
    payload = process_voice(
        transcription,
        language,
        langsmith_extra={"metadata": {"language": language}},
    )
    return _voice_audio_response(payload, language)


# ══════════════════════════════════════════════════════════════════
# DIAGNOSE ENDPOINT — leaf image in, mp3 audio out
# ══════════════════════════════════════════════════════════════════

@traceable(
    name="sakhi_diagnose",
    run_type="chain",
    project_name=_LANGSMITH_PROJECT,
    tags=_TRACE_TAGS,
)
def process_diagnose(file_path: str, language: str) -> str:
    """
    Analyzes a leaf image for disease diagnosis using Gemini Vision.
    Returns the diagnosis text in the specified language.
    """
    return analyze_leaf_image(file_path, language=language)


@app.post("/diagnose")
async def diagnose_crop(file: UploadFile = File(...), language: str = "hi"):
    """
    POST /diagnose — accepts a leaf image upload and optional language code.
    Analyzes the image for crop disease → generates diagnosis → converts to MP3 audio.
    Returns an MP3 audio response or JSON fallback.
    """
    ext = os.path.splitext(file.filename)[1] or ".jpg"
    file_path = f"uploads/{uuid.uuid4()}{ext}"

    # Save uploaded image to disk
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Run vision-based diagnosis and convert to audio
    diagnosis = process_diagnose(
        file_path,
        language,
        langsmith_extra={"metadata": {"language": language}},
    )
    audio_bytes = text_to_speech(diagnosis, language_code=language)

    if audio_bytes:
        return Response(content=audio_bytes, media_type="audio/mpeg")
    return {"diagnosis": diagnosis, "language": language}


# ══════════════════════════════════════════════════════════════════
# MANDI PRICES
# ══════════════════════════════════════════════════════════════════

@app.get("/mandi")
def mandi_prices(crop: str = "wheat", state: str = "UP"):
    """
    GET /mandi — fetches live mandi (market) prices for a given crop and state.
    Returns price data from the government API.
    """
    try:
        price_data = get_mandi_price(crop, state)
        return {"prices": [{"crop": crop, "state": state, "data": price_data}]}
    except Exception as e:
        return {"prices": [], "error": str(e)}


# ══════════════════════════════════════════════════════════════════
# GOVERNMENT SCHEMES
# ══════════════════════════════════════════════════════════════════

@app.get("/schemes")
def govt_schemes(state: str = "UP"):
    """
    GET /schemes — returns a static list of major Indian government agricultural schemes.
    Includes PM-KISAN, PMFBY (crop insurance), and Kisan Credit Card.
    """
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
    """
    POST /sos — receives an emergency SOS alert with GPS coordinates and message.
    Logs the alert and returns confirmation. TODO: integrate with WhatsApp Cloud API.
    """
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
    """
    GET /sync-status — returns the current data sync status.
    Used by the frontend to show whether the backend is online and data is fresh.
    """
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
    """
    GET /rag-query — debug endpoint that returns raw ChromaDB search results.
    Useful for testing RAG retrieval without going through the full chat pipeline.
    """
    try:
        return search_documents(query)
    except Exception as e:
        return {"error": str(e)}