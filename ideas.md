# Sakhi — Kisan Ka Digital Saathi

### Product Idea Document — Vision, Current State, and Future Scope

> "Sakhi" (साखी) — a trusted companion. For India's farmers, a voice-first, AI-powered agricultural assistant that works in the field, offline, and in their language.

---

## Vision

Sakhi is a mobile-first platform built for Indian farmers — smallholders, tribal cultivators, and agri-entrepreneurs — who need real intelligence at the point of decision: standing in the field, haggling at the mandi, applying fertilizer at dawn. It combines AI, government data, and conversational interfaces into one unified, voice-first experience designed for low-connectivity, low-literacy environments.

This document tracks both the original product vision and the actual implementation status based on the current codebase, along with newly identified features that the existing technology stack makes feasible.

---

## Document Structure

- **Part A** — Core Vision Features (originally scoped, with current implementation status)
- **Part B** — Implemented but Previously Undocumented Features
- **Part C** — New Future Scope Ideas (grounded in the current tech stack)
- **Architecture Principles**
- **Tech Stack (Current)**
- **Roadmap**
- **Impact Potential**

---

## Part A: Core Vision Features

---

### 1. Crop Disease Image Detection

**Status:** Implemented (cloud-based)

**What it does:**
Farmers photograph a diseased leaf, fruit, or plant using their phone camera. Sakhi's AI model identifies the disease, pest, or deficiency and returns an actionable diagnosis in the farmer's local language.

**How it works:**
- Implemented using Google Gemini Vision rather than a fine-tuned on-device model as originally scoped
- Takes a leaf image and identifies diseases, pests, or nutrient deficiencies
- Returns a diagnosis with remedies in the requested language
- Backend endpoint handles image upload and processing

**Gap from original scope:**
- No on-device inference (originally planned as a quantized ONNX/TFLite model under 50MB) — current implementation is fully cloud-dependent, meaning it does not work offline
- No multi-image session diagnosis, no community disease heatmaps, no KVK escalation integration

**Future scope:**
- Multi-image session diagnosis (stem, leaf, and root combined)
- Video scan mode for field-wide spread detection
- Community-sourced disease heatmaps by district
- Integration with Krishi Vigyan Kendras (KVKs) for expert escalation
- On-device fallback model for offline diagnosis

---

### 2. Live Market Price API (Mandi Prices)

**Status:** Implemented

**What it does:**
Real-time mandi prices for any crop, at any APMC market, surfaced in a simple, voice-readable format.

**How it works:**
- Integrated with the data.gov.in API, fetching live mandi arrivals and prices
- Maps Hindi crop names to API commodity names
- Returns minimum, maximum, and modal prices per quintal

**Gap from original scope:**
- No price trend graphs (7-day, 30-day, seasonal)
- No "should I sell today?" smart signal
- No price threshold notifications
- eNAM integration not yet built

**Future scope:**
- ML-based price forecasting using historical patterns, weather, and arrival volumes
- Export price parity comparisons against MSP and export benchmarks
- Inter-mandi arbitrage suggestions
- Price trend visualization in the app

---

### 3. Government Loan and Scheme Discovery

**Status:** Partially Implemented

**What it does:**
A directory of government agricultural loans, subsidies, insurance schemes, and input support programs.

**How it works:**
- A static scheme dataset exists in the frontend (demo_schemes.dart)
- Covers schemes such as PM-KISAN, KCC, and PMFBY at a basic informational level

**Gap from original scope:**
- No eligibility engine — the original vision called for matching a farmer's profile (state, land size, category, crop) against applicable schemes automatically
- No application status tracker, no document upload or auto-fill, no grievance filing assistant

**Future scope:**
- Voice-based eligibility checker (see Part C, Section 21)
- Eligibility engine matching farmer profile to applicable schemes
- Step-by-step application guide with document checklist
- Status tracker for submitted applications
- Bank branch locator for KCC applications

---

### 4. Offline-First Architecture

**Status:** Partially Implemented

**What it does:**
Core functionality is intended to work without internet connectivity, syncing automatically when connectivity is restored.

**How it works:**
- Currently limited to basic offline fallback data
- No local persistent database sync layer
- ChromaDB is locally persistent on the backend (PersistentClient), but this does not extend offline capability to the mobile client

**Gap from original scope:**
- No local-first data model on-device (SQLite/Realm as originally scoped)
- No on-device AI models — disease detection and advisory both require connectivity
- No offline voice processing
- No background sync logic

**Future scope:**
- Local-first data model for farm profiles, crop logs, and advice history
- On-device AI models for disease detection and basic voice commands
- Offline document caching for ICAR guides (see Part C, Section 20)
- Background sync when connectivity is detected
- Progressive degradation messaging ("Using last synced data from 2 hours ago")

---

### 5. Voice-First Farmer Marketplace

**Status:** Not Started

**What it does:**
Farmers list produce for sale using only their voice; buyers discover and contact sellers without requiring smartphone literacy or typing.

**How it works (proposed):**
- Farmer states commodity, quantity, price, and location in natural speech
- Sakhi extracts structured listing data automatically
- Buyers browse listings by crop, location, and quantity
- Contact made via in-app call or WhatsApp Business API

**Future scope:**
- Hyperlocal B2B matching with restaurants, processors, and institutional buyers
- Group selling — aggregating small lots into bulk quantities
- Cold storage availability integration
- Voice-based negotiation assistance

---

### 6. Fertilizer Requirement Calculator

**Status:** Not Started (see related new feature in Part C, Section 15)

**What it does:**
Calculates precise N-P-K fertilizer requirements based on crop, growth stage, soil data, and field size.

**Future scope:**
- See Part C, Section 15 — Voice-Based Fertilizer Calculator, which proposes building this directly on top of the existing RAG and intent-classification infrastructure rather than as a standalone module

---

### 7. Crop Risk Alerts via Weather APIs

**Status:** Partially Implemented

**What it does:**
Proactive, crop-specific weather risk alerts delivered before the event.

**How it works:**
- Weather data integrated via OpenWeatherMap
- Generates general farming-specific advice (for example, avoid spraying in rain, frost warnings)

**Gap from original scope:**
- No crop-specific risk engine mapping weather events to growth-stage-specific outcomes
- No district-level historical climate risk maps
- No insurance-claim documentation trigger for PMFBY

**Future scope:**
- Crop-specific risk engine tied to growth stage and weather thresholds
- Historical climate risk maps by district
- Insurance trigger alerts that document weather events for PMFBY claim support
- Monsoon onset tracker with sowing window advisory

---

### 8. AI Crop Advisory (Soil and Weather Context)

**Status:** Partially Implemented

**What it does:**
Personalized crop advice combining soil, weather, and growth-stage context, delivered conversationally in the farmer's language.

**How it works:**
- A working RAG pipeline (ChromaDB plus sentence-transformer embeddings) retrieves relevant agricultural documents
- NVIDIA Llama 3.1 generates multilingual responses grounded in retrieved context
- Supports seven languages: Hindi, Telugu, Marathi, Tamil, Kannada, Bengali, English

**Gap from original scope:**
- No crop growth-stage registry — advisory is currently general-purpose rather than tied to a farmer's specific logged crop and stage
- No agronomist escalation path
- No comparative advice between farmers in similar conditions

**Future scope:**
- Crop registry linking advisory to a farmer's actual logged crop, sowing date, and growth stage
- Agronomist escalation for low-confidence queries
- Crop calendar generation (see Part C, Section 16)
- Comparative advice based on similar soil and regional conditions

---

### 9. Microclimate Farming Sensor Integration

**Status:** Not Started

**What it does:**
Connects to low-cost IoT sensors (soil moisture, temperature, humidity, NPK) and translates sensor data into plain-language farming decisions.

**Future scope:**
- Low-cost sensor kits assembled by local self-help groups
- Village-level LoRa gateway network
- Automated irrigation integration
- Microclimate modeling across multiple sensor nodes
- Carbon credit linkage based on verified water and fertilizer savings

---

## Part B: Implemented but Previously Undocumented Features

These features exist in the current codebase but were not captured in the original product vision document.

---

### 10. RAG-Powered Agricultural Knowledge Base

**Status:** Implemented

**What it does:**
Farmers ask any agricultural question in their language, and Sakhi retrieves relevant information from ICAR documents and verified agricultural guides, then generates a grounded answer.

**How it works:**
- ICAR PDFs are ingested through a pipeline that extracts text, chunks it with sentence-aware boundaries, and stores embeddings in ChromaDB
- Metadata extraction auto-tags documents by crop, disease, fertilizer, and irrigation keywords
- Top three relevant document chunks are retrieved using semantic similarity for each query
- NVIDIA Llama 3.1 generates an answer grounded in the retrieved context
- LangSmith tracing monitors retrieval and generation quality

**Future scope:**
- Citation display showing which ICAR document an answer came from
- Multi-document synthesis for complex questions
- Farmer-submitted knowledge, reviewed by verified agronomists
- Voice-based document search
- Offline document caching for common crops (see Part C, Section 20)

---

### 11. Intent-Aware Conversational Routing

**Status:** Implemented

**What it does:**
Automatically detects what the farmer wants — price check, disease diagnosis, scheme information, weather advisory, or emergency help — and routes the query to the correct backend service.

**How it works:**
- Intent classifier (NVIDIA LLM, low temperature) categorizes queries into six intents: price, disease, scheme, weather, sos, and general
- SOS detection uses fast-path keyword matching for immediate emergency response
- Intent determines which downstream service is invoked: mandi prices, disease diagnosis, scheme lookup, weather advisory, emergency helplines, or general RAG retrieval

**Future scope:**
- Multi-intent query handling (for example, price and weather in a single query)
- Context carryover for follow-up questions
- Confidence scoring with clarifying questions below a defined threshold
- Voice tone analysis to prioritize urgent or distressed queries
- Personalized intent learning over time

---

### 12. SOS Emergency Helpline Integration

**Status:** Partially Implemented

**What it does:**
One-tap access to emergency services — ambulance, police, and women's helpline — with tap-to-call functionality.

**How it works:**
- SOS tab displays emergency contacts with localized labels in all seven supported languages
- Tap-to-call launches the phone dialer with a pre-filled number
- Backend /sos endpoint has structure in place for logging GPS coordinates and message data

**Gap:**
- WhatsApp Cloud API integration for automated alert messages is not yet connected

**Future scope:**
- WhatsApp Cloud API integration to auto-send SOS messages with GPS to designated contacts
- Pre-registered trusted contacts
- Voice-activated SOS triggering
- Offline SOS queuing, sent when connectivity is restored
- Community SOS broadcast to nearby Sakhi users

---

## Part C: New Future Scope Ideas

These features are not yet built but are directly feasible using the existing tech stack — LangChain, FastAPI, NVIDIA Llama 3.1, ChromaDB, and Whisper — without major architectural changes.

---

### 13. Multi-Turn Conversational Memory

**What it does:**
Sakhi remembers the context of the current conversation, allowing farmers to ask follow-up questions without repeating themselves.

**How it works:**
- Introduce a session identifier to track conversation context
- Retrieve the last three to five conversation turns as context for the LLM
- Clear the session after thirty minutes of inactivity or an explicit reset command

**Why it's feasible:**
- ChromaDB infrastructure already exists for embedding storage
- NVIDIA Llama 3.1 supports sufficiently long context windows
- The existing intent classifier can be extended to detect follow-up versus new queries

**Future scope:**
- Persistent conversation history across sessions
- Voice-based conversation replay
- Conversation summarization for long sessions
- Exportable conversation history

---

### 14. Voice-Based ICAR Document Question and Answer

**What it does:**
Farmers ask specific questions about ICAR agricultural guides and receive answers with exact source references.

**How it works:**
- Builds on the existing RAG pipeline (ingest_icar.py and chromadb_module.py)
- Adds source tracking — page number, chapter, and document name — to retrieval metadata
- Displays a citation alongside each response

**Why it's feasible:**
- ICAR ingestion already extracts metadata
- ChromaDB supports metadata filtering
- The LLM can be prompted to include citations directly in its output

**Future scope:**
- Document browser showing available ICAR guides by crop
- Bookmarking for offline access
- Multi-document comparison across sources
- Audio summaries of individual chapters

---

### 15. Voice-Based Fertilizer Calculator

**What it does:**
Farmers describe their crop, field size, and growth stage in natural speech, and Sakhi calculates the exact fertilizer requirement based on ICAR guidelines.

**How it works:**
- Parse voice input for crop, area, and growth stage
- Query the RAG knowledge base for ICAR fertilizer recommendations
- Calculate the required quantity and return a spoken response with application timing

**Why it's feasible:**
- The intent classifier can be extended to detect a fertilizer-related intent
- The RAG pipeline already contains ICAR fertilizer data
- The LLM can perform unit conversion and basic calculation

**Future scope:**
- Soil health card integration via photo capture
- Cost calculator with nearby shop suggestions
- Reminder scheduling for follow-up doses
- Organic fertilizer alternatives

---

### 16. Crop Calendar Generator

**What it does:**
Generates a full-season calendar with weekly action items — sowing, irrigation, fertilizer, weeding, harvest — based on crop, location, and sowing date.

**How it works:**
- Parse crop, location, and sowing date from a voice or text query
- Query the weather API for a fourteen-day forecast
- Query the RAG knowledge base for ICAR crop calendars
- Generate a week-by-week plan with weather-aware adjustments

**Why it's feasible:**
- The weather integration already exists
- The RAG pipeline contains agricultural calendar data
- The LLM can generate structured, multi-step plans

**Future scope:**
- Push notifications for upcoming calendar actions
- Weather-based plan adjustments
- Progress tracking as farmers complete each step
- Community-level calendar comparison

---

### 17. Voice Translation Between Languages

**What it does:**
A farmer speaks in one supported language and Sakhi translates and responds in another, useful for migrant farmers or cross-regional knowledge sharing.

**How it works:**
- Whisper transcribes the spoken input
- The LLM translates the transcribed text to the target language
- TTS speaks the response in the target language voice

**Why it's feasible:**
- Whisper already supports the relevant transcription languages
- NVIDIA Llama 3.1 is capable of translation
- TTS already supports all seven target languages

**Future scope:**
- Real-time two-way conversation mode between farmers
- Agricultural term dictionary to ensure correct technical translation
- Dialect-level support
- Offline translation cache for common phrases

---

### 18. Knowledge Base Browsing with Metadata Filtering

**What it does:**
Farmers can request a comprehensive overview of a topic — for example, all wheat diseases — and Sakhi retrieves and synthesizes every relevant ICAR document.

**How it works:**
- Query ChromaDB using metadata filters (crop type, disease tag, fertilizer tag, irrigation tag)
- Retrieve all matching documents
- LLM synthesizes the results into a single coherent answer

**Why it's feasible:**
- Metadata extraction already exists in the ICAR ingestion pipeline
- ChromaDB natively supports metadata filtering
- The LLM can synthesize across multiple retrieved documents

**Future scope:**
- Interactive filtering by sub-category
- Severity-based ranking of results
- Image gallery alongside textual descriptions
- Voice-based sequential browsing

---

### 19. Voice-Based Agri-Input Shop Locator

**What it does:**
Farmers describe a need — for example, running out of urea — and Sakhi locates nearby agri-input shops carrying that product.

**How it works:**
- Parse product and location (GPS or registered village) from the query
- Query a shop database for product availability
- Return shop name, distance, and contact number, with optional direct call

**Why it's feasible:**
- Location services already exist in the Flutter app
- TTS can speak shop details aloud
- Tap-to-call functionality already exists for the SOS feature

**Future scope:**
- Real-time shop inventory integration
- Price comparison across nearby shops
- Home delivery ordering
- Shop ratings from farmer reviews

---

### 20. Offline Document Caching

**What it does:**
Farmers download a seasonal content pack over WiFi — for example, ICAR wheat guide, fertilizer calculator data, and common disease references — that then works fully offline.

**How it works:**
- Pre-load relevant document chunks for common crops onto the device
- Cache TTS audio for frequently requested responses
- Sync new documents when WiFi becomes available

**Why it's feasible:**
- ChromaDB already supports local persistence on the backend
- Flutter has built-in offline storage capabilities
- TTS audio can be cached locally as audio files

**Future scope:**
- Seasonal packs covering multiple crops per growing season
- Smart caching based on a farmer's registered crops
- Storage-optimized compression for low-end devices
- Peer-to-peer sharing between farmers via Bluetooth

---

### 21. Voice-Based Scheme Eligibility Checker

**What it does:**
Farmers describe their land size and category in natural speech, and Sakhi checks eligibility against schemes such as PM-KISAN, KCC, and PMFBY.

**How it works:**
- Parse land size and category from the query
- Query a scheme eligibility ruleset
- Return eligible schemes, benefit amounts, and application links

**Why it's feasible:**
- Scheme data already exists in the frontend (demo_schemes.dart)
- The LLM can evaluate structured eligibility rules
- The intent classifier already detects a scheme-related intent

**Future scope:**
- Document upload with auto-fill of application forms
- Application status tracking
- Bank branch locator for credit-linked schemes
- Side-by-side comparison of multiple eligible schemes

---

## Architecture Principles

| Principle | Detail |
|-----------|--------|
| Voice-first | Every feature accessible via voice command in seven Indian languages |
| Offline-first | Core functionality should work without internet; currently partially implemented |
| Low-data mode | Designed for constrained connectivity; compressed data transfers where possible |
| Privacy | Farm data handling should favor on-device storage with opt-in cloud sync |
| Interoperability | Open APIs to connect with government and market data sources |
| Low-literacy UX | Icon-first UI, audio feedback, minimal text input required |

---

## Tech Stack (Current)

| Layer | Stack |
|-------|-------|
| Mobile App | Flutter (Dart) |
| Backend Framework | FastAPI (Python) |
| Intent Classification | LangChain plus NVIDIA LLM zero-shot classification |
| LLM Layer | NVIDIA Llama 3.1 8B |
| Vision (Disease Diagnosis) | Google Gemini Vision |
| RAG / Knowledge Base | ChromaDB plus sentence-transformers (all-MiniLM-L6-v2) |
| Speech-to-Text | faster-whisper (tiny model) |
| Text-to-Speech | Google Cloud TTS (seven Indian languages) |
| Weather Data | OpenWeatherMap |
| Market Prices | data.gov.in Agmarknet API |
| Observability | LangSmith |

Note: the original product vision specified React Native, Claude API, and Node.js. The current implementation uses Flutter, NVIDIA Llama 3.1, and FastAPI instead. This document reflects the actual stack in use.

---

## Roadmap

```
Phase 1 (Foundation — current)
- Voice-first crop advisory with RAG knowledge base (implemented)
- Crop disease image detection via Gemini Vision (implemented)
- Live mandi price lookup (implemented)
- Intent-aware conversational routing (implemented)
- SOS emergency helpline (partially implemented)

Phase 2 (Depth and Completion — next)
- Voice-based fertilizer calculator
- Crop calendar generator
- Scheme eligibility checker
- Multi-turn conversational memory
- WhatsApp SOS integration completion
- Offline document caching

Phase 3 (Scale — future)
- Voice-first farmer marketplace
- IoT sensor integration and precision irrigation
- ML-based price forecasting
- Offline-first local data model on-device
- On-device disease detection model
```

---

## Impact Potential

- Over 140 million smallholder farmers in India represent the primary addressable audience
- Reduced post-harvest losses through timely market access
- Increased farmer income through improved price discovery and input optimization
- Climate resilience through proactive, crop-specific weather alerts
- Financial inclusion by surfacing government schemes that are otherwise difficult to discover

---

*Document version: 0.2 — Updated against current codebase*
*Next step: prioritize Phase 2 features that build directly on the existing RAG and intent-classification infrastructure*
