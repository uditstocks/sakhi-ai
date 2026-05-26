#  Sakhi AI

> **An AI-powered voice assistant for Indian farmers** - crop disease detection, mandi prices, weather, government schemes, and emergency SOS, all in Hindi and regional languages.

---

## What is Sakhi AI?

Sakhi AI is a multilingual agricultural assistant built for rural and semi-urban farmers across India. It removes the language and literacy barrier between farmers and critical farming information by supporting voice input, regional language output, and offline-friendly design.

**Core capabilities:**

-  **Crop disease detection** - description of crop disease 
-  **Voice chat** - speak in Hindi/Marathi/Punjabi, get spoken answers back
-  **Live mandi prices** - real-time crop prices from local mandis
-  **Government schemes** - PM-KISAN, PMFBY, Kisan Credit Card info
-  **SOS alerts** - one-tap emergency alert with GPS location

---

## Architecture Overview

```
Sakhi App (mobile / web)
        │
        │  HTTPS
        ▼
┌──────────────────────────────┐
│   LangChain\FastAPI Backend (main.py)  │
│   + LangSmith tracing        │
└──────┬───────────────────────┘
       │
       ├── /chat      → Intent classify → RAG (ChromaDB) → LLM
       ├── /voice     → Whisper STT → Intent → LLM → TTS (mp3)
       
       ├── /mandi     → Mandi price API
       ├── /schemes   → Static scheme data
       └── /sos       → alert
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| **API framework** | FastAPI + Uvicorn + LangChain |
| **Disease detection** | LLaMA 3.2 Vision 11B (self-hosted via Ollama) |
| **Speech-to-text** | OpenAI Whisper |
| **Text-to-speech** | TTS module (Hindi/regional) |
| **LLM (chat)** | LLM module with intent routing |
| **Vector DB / RAG** | ChromaDB |
| **Intent classification** | LangChain |
| **Observability** | LangSmith |
| **Caching** | Redis |

---

## Project Structure

```
sakhi-ai/
├── main.py                  # FastAPI app — all endpoints
├── llama_vision_module.py   # LLaMA 3.2 Vision disease detection
├── gemini_module.py         # (legacy) Gemini vision — replaced by llama
├── llm_module.py            # LLM chat with intent-aware prompting
├── whisper_module.py        # Audio transcription (Whisper)
├── tts_module.py            # Text-to-speech (Hindi + regional)
├── chromadb_module.py       # RAG vector search
├── langchain_module.py      # Intent classifier
├── market_module.py         # Mandi price fetcher
├── weather_module.py        # Weather API wrapper
├── langsmith_setup.py       # LangSmith tracing config
├── setup_llama_vision.sh    # One-time Ollama + model setup
├── uploads/                 # Temp image/audio uploads
└── requirements.txt
```

---

## Getting Started

### Prerequisites

- Python 3.10+
- 16 GB RAM minimum (32 GB recommended for LLaMA 11B)
- NVIDIA GPU with 16 GB VRAM (optional but recommended for vision)

### 1. Clone and install

```bash
git clone https://github.com/your-org/sakhi-ai.git
cd sakhi-ai
pip install -r requirements.txt
```

### 2. Set up LLaMA 3.2 Vision (self-hosted)

```bash
chmod +x setup_llama_vision.sh
./setup_llama_vision.sh
```

This installs [Ollama](https://ollama.com), pulls the `llama3.2-vision` 11B model (~8 GB), and starts the local inference server.

### 3. Configure environment variables

Create a `.env` file in the project root:

```env
# LangSmith (observability)
LANGSMITH_API_KEY=your_key_here
LANGSMITH_PROJECT=sakhi-ai
LANGSMITH_TRACING_V2=true

# LLaMA Vision (self-hosted)
LLAMA_BACKEND=ollama           # or "vllm" for production
OLLAMA_URL=http://localhost:11434
LLAMA_MODEL=llama3.2-vision
LLAMA_TIMEOUT=60

# Optional: vLLM (production inference)
VLLM_URL=http://localhost:8000
```

### 4. Start the server

```bash
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

Visit `http://localhost:8080/health` to verify everything is running.

---

## API Reference

### `GET /health`
Returns service status, LangSmith config, and vision backend info.

---

### `POST /chat`
Text-based query with intent routing.

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
  "intent": "crop_disease",
  "response": "Gehun mein pattaon ka peela hona..."
}
```

---

### `POST /voice`
Accepts an audio file, returns an MP3 audio response.

```bash
curl -X POST http://localhost:8080/voice \
  -F "file=@query.m4a" \
  -F "language=hi" \
  --output response.mp3
```

---

### `POST /diagnose`
Accepts a crop/leaf image, returns an MP3 audio diagnosis.

```bash
curl -X POST http://localhost:8080/diagnose \
  -F "file=@leaf.jpg" \
  -F "language=hi" \
  --output diagnosis.mp3
```

**Vision model behavior:**
- Identifies disease name, visible symptoms, and recommended treatment
- Responds in the specified regional language
- Falls back gracefully if the model server is unavailable

---

### `GET /mandi?crop=wheat&state=UP`
Returns live mandi prices for a crop and state.

---

### `GET /weather?location=Lucknow`
Returns a farmer-friendly weather summary.

---

### `GET /schemes?state=UP`
Returns relevant government schemes (PM-KISAN, PMFBY, KCC, etc.).

---

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

---

## Intent Classification

The `/chat` and `/voice` endpoints automatically classify user intent and route accordingly:

| Intent | Trigger examples | Routed to |
|---|---|---|
| `price` | "gehun ka bhav", "mandi rate" | Mandi API → LLM |
| `weather` | "kal barish hogi?", "mausam kaisa" | Weather API → LLM |
| `sos` | Emergency keywords | SOS alert + WhatsApp |
| `general` | All other queries | ChromaDB RAG → LLM |

---

## Supported Languages

| Code | Language |
|---|---|
| `hi` | Hindi |
| `en` | English |
| `mr` | Marathi |
| `pa` | Punjabi |

---

## Switching Vision Backends

**Development (Ollama — easier setup):**
```env
LLAMA_BACKEND=ollama
OLLAMA_URL=http://localhost:11434
```

**Production (vLLM — better throughput):**
```env
LLAMA_BACKEND=vllm
VLLM_URL=http://localhost:8000
```

No code changes needed — just update the env var and restart.

---

## Observability

All endpoints are traced with [LangSmith](https://smith.langchain.com):

| Trace name | Type | Endpoint |
|---|---|---|
| `sakhi_chat` | chain | `/chat` |
| `sakhi_voice` | chain | `/voice` |
| `sakhi_diagnose` | chain | `/diagnose` |
| `sakhi_rag_search` | retriever | internal |

Set `LANGSMITH_API_KEY` and `LANGSMITH_PROJECT` in your `.env` to enable.

---

## Roadmap

- [ ] WhatsApp Cloud API integration for SOS alerts
- [ ] Offline mode with cached model responses
- [ ] Expand language support (Bengali, Telugu, Gujarati)
- [ ] Fine-tune LLaMA on Indian crop disease dataset
- [ ] Android app with on-device Whisper STT

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

---

## License

MIT
