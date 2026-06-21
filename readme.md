# Sakhi AI

> An AI-powered voice assistant for Indian farmers — crop disease detection, mandi prices, weather, government schemes, and emergency SOS, in Hindi and six regional languages.

---

## What is Sakhi AI?

Sakhi AI is a multilingual agricultural assistant built for rural and semi-urban farmers across India. It removes the language and literacy barrier between farmers and critical farming information by supporting voice input, regional language output, and a retrieval-grounded knowledge base built on verified agricultural sources.

The project consists of a FastAPI backend and a Flutter mobile application.

**Core capabilities:**

- **Crop disease detection** — photograph a leaf and receive a diagnosis with treatment guidance, spoken back in the farmer's language
- **Voice chat** — speak in Hindi or a regional language, get a spoken answer back
- **Live mandi prices** — real-time crop prices by state and commodity
- **Government schemes** — information on PM-KISAN, PMFBY, Kisan Credit Card, and related programs
- **Agricultural knowledge base** — answers grounded in ingested ICAR documents via retrieval-augmented generation
- **SOS alerts** — emergency alert endpoint with GPS coordinates

---

## Architecture Overview

```
Sakhi App (Flutter — frontend/)
        │
        │  HTTPS
        ▼
┌────────────────────────────────────────┐
│   FastAPI Backend (backend/main.py)     │
│   + LangSmith tracing                   │
└──────┬───────────────────────────────────┘
       │
       ├── /chat        → Intent classify (LangChain) → RAG (ChromaDB) → LLM (NVIDIA Llama 3.1)
       ├── /voice        → Whisper STT → Intent → LLM → TTS (mp3)
       ├── /diagnose      → Gemini Vision → diagnosis → TTS (mp3)
       ├── /mandi        → Mandi price API (data.gov.in)
       ├── /schemes      → Static scheme data
       ├── /sos          → Emergency alert logging
       ├── /rag-query      → Direct ChromaDB retrieval (debug / internal)
       └── /sync-status      → Cache status (currently a stub)
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| API framework | FastAPI + Uvicorn |
| Mobile app | Flutter (Dart) |
| Disease detection (vision) | Google Gemini 2.5 Flash, via `google-genai` |
| Chat LLM | NVIDIA Llama 3.1 8B |
| Speech-to-text | faster-whisper |
| Text-to-speech | Google Cloud Text-to-Speech |
| Vector DB / RAG | ChromaDB with sentence-transformers embeddings |
| Intent classification | LangChain |
| Observability | LangSmith |
| Document ingestion | Custom pipeline for ICAR PDF and text sources |

---

## Project Structure

```
sakhi-ai/
├── backend/
│   ├── main.py                  # FastAPI app — all route handlers
│   ├── langsmith_setup.py       # LangSmith tracing config (import first)
│   ├── chromadb_module.py       # RAG vector store and retrieval
│   ├── AI_services/
│   │   ├── gemini_module.py     # Crop disease diagnosis via Gemini Vision
│   │   ├── tts_module.py        # Text-to-speech, 7 languages
│   │   └── whisper_module.py    # Speech-to-text
│   ├── nlp/
│   │   ├── langchain_module.py  # Intent classifier
│   │   └── llm_module.py        # Chat generation via NVIDIA Llama 3.1
│   ├── external_APIs/
│   │   ├── market_module.py     # Mandi price fetcher
│   │   └── weather_module.py    # Weather data wrapper
│   ├── ingestion/
│   │   ├── ingest.py            # Sample document seeding
│   │   ├── ingest_icar.py       # ICAR PDF ingestion pipeline
│   │   └── load_docs.py         # Bulk text document ingestion
│   └── requirements.txt
└── frontend/                    # Flutter application (active)
```

> Note: the repository also contains a `flutter_sakhi/` directory at the root. This is a leftover from an earlier build and contains no source code — `frontend/` is the actively developed Flutter app.

---

## Getting Started

### Prerequisites

- Python 3.10+
- Flutter SDK (stable channel)
- API keys for: NVIDIA NIM (chat LLM), Google Gemini (vision), Google Cloud (text-to-speech), LangSmith (optional, for tracing)

### 1. Clone the repository

```bash
git clone https://github.com/kan9667/sakhi-ai.git
cd sakhi-ai
```

### 2. Backend setup

```bash
cd backend
pip install -r requirements.txt
```

Create a `.env` file inside `backend/`:

```env
# NVIDIA Llama 3.1 (chat LLM)
LLM_KEY=your_nvidia_api_key

# Google Gemini (crop disease vision)
GEMINI_API_KEY=your_gemini_api_key

# Google Cloud Text-to-Speech
GOOGLE_APPLICATION_CREDENTIALS=gcloud_key.json

# LangSmith (observability — optional)
LANGSMITH_API_KEY=your_langsmith_key
LANGSMITH_PROJECT=sakhi-ai
LANGSMITH_TRACING_V2=true
```

Start the backend:

```bash
uvicorn main:app --reload
```

By default this serves on `http://localhost:8000`. Visit `/health` to confirm the service is running.

### 3. Frontend setup

```bash
cd frontend
flutter pub get
flutter run
```

For a web build:

```bash
flutter build web --release
```

---

## API Reference

### `GET /`
Root endpoint — basic service metadata.

### `GET /health`
Returns service status and configuration info, including LangSmith tracing state.

### `POST /chat`
Text-based query with automatic intent routing.

**Request body:**
```json
{
  "query": "Gehun mein koi bimari lag gayi hai",
  "language": "hi"
}
```

**Response:**
```json
{
  "intent": "disease",
  "response": "Gehun mein pattaon ka peela hona..."
}
```

### `POST /voice`
Accepts an audio file, returns an MP3 audio response.

```bash
curl -X POST http://localhost:8000/voice \
  -F "file=@query.m4a" \
  -F "language=hi" \
  --output response.mp3
```

### `POST /diagnose`
Accepts a crop or leaf image, returns an MP3 audio diagnosis generated via Gemini Vision.

```bash
curl -X POST http://localhost:8000/diagnose \
  -F "file=@leaf.jpg" \
  -F "language=hi" \
  --output diagnosis.mp3
```

The model identifies the disease name, visible symptoms, and recommended treatment, and responds in the specified language.

### `GET /mandi`
Returns live mandi prices.

**Query parameters:** `crop` (default `"wheat"`), `state` (default `"UP"`)

### `GET /schemes`
Returns relevant government schemes.

**Query parameters:** `state` (default `"UP"`)

### `POST /sos`
Registers an SOS alert with GPS coordinates.

**Request body:**
```json
{
  "latitude": 26.8467,
  "longitude": 80.9462,
  "message": "Madad chahiye!"
}
```

WhatsApp Cloud API delivery for SOS alerts is not yet implemented — this is tracked as a TODO in the codebase and listed under Roadmap below.

### `GET /rag-query`
Returns raw ChromaDB search results for a given query — documents, distances, metadata, and assembled context.

This is an internal debugging endpoint for testing retrieval quality directly, not intended for end-user traffic. It returns unformatted vector search output rather than a generated answer.

### `GET /sync-status`
Returns cache and sync status information.

This endpoint currently returns static placeholder values and does not reflect real backend state. It exists as a stub for a planned future feature.

---

## Intent Classification

The `/chat` and `/voice` endpoints classify each query into one of six intents and route accordingly:

| Intent | Trigger examples | Routed to |
|---|---|---|
| `price` | "gehun ka bhav", "mandi rate" | Mandi API → LLM |
| `disease` | descriptions of crop symptoms | RAG knowledge base → LLM |
| `scheme` | "PM-KISAN kaise milega" | Scheme data → LLM |
| `weather` | "kal barish hogi?", "mausam kaisa" | Weather API → LLM |
| `sos` | emergency keywords | SOS alert logging |
| `general` | all other queries | ChromaDB RAG → LLM |

---

## Supported Languages

| Code | Language |
|---|---|
| `hi` | Hindi |
| `en` | English |
| `mr` | Marathi |
| `te` | Telugu |
| `ta` | Tamil |
| `kn` | Kannada |
| `bn` | Bengali |

---

## Agricultural Knowledge Base

Sakhi AI's general and disease-related answers are grounded in a retrieval-augmented generation pipeline built on ChromaDB:

- ICAR PDF guides are ingested via `ingest_icar.py`, which extracts text, chunks it, and auto-tags it by crop, disease, fertilizer, and irrigation keywords
- `load_docs.py` ingests plain-text agricultural documents in bulk
- `ingest.py` seeds a small sample dataset for local development and testing
- Retrieval uses sentence-transformer embeddings, returning the most relevant document chunks for each query before generation

---

## Observability

Backend operations are traced with [LangSmith](https://smith.langchain.com) when configured. Set `LANGSMITH_API_KEY` and `LANGSMITH_PROJECT` in your `.env` to enable tracing across the chat, voice, and diagnosis pipelines.

---

## Roadmap

- [ ] Complete WhatsApp Cloud API integration for SOS alerts (currently a TODO in `main.py`)
- [ ] Replace `/sync-status` stub with real cache and sync state reporting
- [ ] Restrict or formalize `/rag-query` as a proper internal/admin-only endpoint
- [ ] Offline mode with cached responses for low-connectivity areas
- [ ] Expand language support beyond the current seven
- [ ] Native Android build with on-device speech-to-text
- [ ] Remove the unused legacy `flutter_sakhi/` directory

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## License

MIT
