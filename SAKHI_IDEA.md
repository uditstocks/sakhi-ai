# 🌾 Sakhi — Kisan Ka Digital Saathi
### Product Idea Document · Future Scope & Feature Vision

> *"Sakhi" (साखी) — a trusted companion. For India's farmers, a voice-first, AI-powered agricultural assistant that works in the field, offline, and in their language.*

---

## Vision

Sakhi is a mobile-first platform built for Indian farmers — smallholders, tribal cultivators, and agri-entrepreneurs — who need real intelligence at the point of decision: standing in the field, haggling at the mandi, applying fertilizer at dawn. It combines AI, IoT, government data, and community commerce into one unified, voice-first experience that works even without reliable internet.

---

## Feature Scope: Detailed Breakdown

---

### 1. 🦠 Crop Disease Image Detection

**What it does:**
Farmers photograph a diseased leaf, fruit, or plant using their phone camera. Sakhi's on-device or cloud AI model identifies the disease, pest, or deficiency — and returns an actionable diagnosis in the farmer's local language.

**How it works:**
- Fine-tuned vision model (e.g., EfficientNet / MobileViT) trained on curated Indian crop disease datasets (PlantVillage + ICAR datasets)
- On-device inference for offline use (quantized ONNX / TFLite model < 50MB)
- Returns: disease name, severity level (mild / moderate / severe), probable cause, and treatment recommendation
- Links to nearby agri-input shops stocking the required pesticide/fungicide
- History log so farmers can track recurrence over seasons

**Future scope:**
- Multi-image session diagnosis (stem + leaf + root = holistic diagnosis)
- Video scan mode for walking through a plot and detecting field-wide spread
- Community-sourced disease heatmaps by district — if 40 farmers in Yavatmal report leaf curl in a week, alert the whole cluster
- Integration with Krishi Vigyan Kendras (KVKs) for expert escalation

---

### 2. 📈 Live Market Price API (Mandi Prices)

**What it does:**
Real-time and historical mandi prices for any crop, at any APMC market, surfaced in a simple, voice-readable format. Farmers know *today's* price before they decide whether to sell or wait.

**How it works:**
- Primary source: [data.gov.in Agmarknet API](https://agmarknet.gov.in) — daily arrivals and prices from 3,000+ mandis
- Secondary: eNAM (National Agriculture Market) API for online-traded commodities
- Price trend graph: 7-day, 30-day, seasonal comparison
- "Should I sell today?" smart signal using 7-day moving average + seasonal baseline
- Push notification when price of user's registered crop crosses a user-defined threshold

**Future scope:**
- ML-based price forecasting: predict mandi price 7–14 days ahead using historical patterns + weather + arrival volumes
- Export price parity: compare farm-gate price vs. MSP vs. export benchmark
- Inter-mandi arbitrage suggestion: "Pune mandi is paying ₹200/quintal more than Nashik today"
- Voice query: *"Aaj aloo ka Agra mandi mein kya bhav hai?"*

---

### 3. 🏦 Government Loan & Scheme Discovery

**What it does:**
A searchable, filterable directory of government agricultural loans, subsidies, insurance schemes, and input support programs — personalized to the farmer's state, crop, land size, and caste category.

**How it works:**
- Structured database of Central + State schemes: PM-KISAN, KCC (Kisan Credit Card), PMFBY (crop insurance), soil health card subsidy, drip irrigation subsidy, NABARD refinance schemes, etc.
- Farmer onboarding collects: state, district, land size (bigha/acre), crop type, category (SC/ST/OBC/General), land ownership status
- Eligibility engine matches profile to applicable schemes
- Step-by-step application guide with document checklist
- Direct link / QR code to the official portal

**Future scope:**
- Status tracker: farmer uploads application reference number, Sakhi polls the portal and notifies on approval/disbursement
- Bank branch locator for KCC with appointment booking via call
- Vernacular document reader: photograph your Aadhaar / land record, auto-fill the application form
- Grievance filing assistant for stuck applications (integration with CPGRAMS / state helplines)

---

### 4. 📶 Offline-First Architecture

**What it does:**
Sakhi works without internet. Core features — disease detection, fertilizer calculator, saved crop advice, offline voice assistant — function fully on-device. Data syncs automatically when connectivity is restored.

**How it works:**
- **Local-first data model**: all farm profiles, crop logs, advice history, and scheme info cached in SQLite / Realm on-device
- **On-device AI models**: quantized disease detection + fertilizer models run entirely on-device (no API call needed)
- **Offline voice**: wake word detection + basic command parsing runs locally using a lightweight model (e.g., Vosk or Whisper-tiny)
- **Background sync**: when 2G/4G/WiFi is detected, syncs mandi prices, weather updates, new scheme info, and uploads field photos for cloud processing
- **Progressive degradation**: features gracefully indicate "Using last synced data from 2 hours ago" instead of failing silently

**Future scope:**
- Mesh networking between nearby farmers' phones (Bluetooth/WiFi Direct) to share mandi prices and weather alerts without internet
- Offline SMS fallback: Sakhi sends formatted crop advice via SMS when data is unavailable (for 2G feature phones)
- Pre-loaded seasonal content packs: download "Kharif 2025 Pack" over WiFi before the season — includes disease guides, weather norms, and scheme updates

---

### 5. 🛒 Voice-First Farmer Marketplace

**What it does:**
Farmers list their produce for sale using only their voice. Local buyers — traders, restaurants, processors, direct consumers — discover and contact sellers. No typing, no forms, no smartphone literacy required.

**How it works:**
- Farmer says: *"Mere paas 20 quintal gehoon hai, ₹2,200 per quintal mein bechna hai, Karnal se"*
- Sakhi extracts: commodity, quantity, price, location → creates a listing automatically
- Buyers (local businesses, aggregators, FPOs) browse by crop/location/quantity on a web dashboard
- Contact is made via in-app call (no number sharing needed) or WhatsApp Business API message
- Seller rating system builds reputation over time

**Future scope:**
- **Hyperlocal B2B matching**: restaurant chains, school mid-day meal suppliers, and local processors can post buy orders; Sakhi matches them with nearby farmers
- **Group selling**: Sakhi aggregates 10 small farmers with 2 quintal each into one 20-quintal lot to unlock better rates from bulk buyers
- **Cold storage integration**: partner cold chain facilities can flag available storage slots; Sakhi suggests "Store now, sell in 3 weeks for better price"
- **Voice negotiation assist**: AI drafts a counter-offer script in local language when buyer proposes a lower price

---

### 6. 🧪 Fertilizer Requirement Calculator

**What it does:**
Based on crop type, growth stage, soil test report, and field size — Sakhi calculates the precise N-P-K (Nitrogen, Phosphorus, Potassium) requirement and recommends the most cost-effective fertilizer combination to meet it.

**How it works:**
- Inputs: crop, variety, sowing date, current growth stage, field area, soil health card data (or manual NPK entry)
- Uses ICAR-recommended nutrient requirements per crop per growth stage
- Outputs: kg of urea / DAP / MOP / micronutrient mix needed for the plot
- Cost calculator: shows total fertilizer cost and flags cheaper generic equivalents
- Reminder schedule: "Apply second dose of urea in 18 days"

**Future scope:**
- Soil health card OCR: photograph the card, auto-extract NPK levels
- Fertigation scheduling for drip-irrigated fields (dose + timing + dilution ratio)
- Organic farming mode: compost / vermicompost / neem cake equivalents
- Retailer integration: order the exact quantity from a nearby agri-input store with one tap
- Overapplication warnings with environmental cost context ("Excess urea leaches into groundwater")

---

### 7. 🌩️ Crop Risk Alerts via Weather APIs

**What it does:**
Proactive, crop-specific weather risk alerts delivered before the event — not generic forecasts but translated risk: *"Frost risk in next 48 hours — cover your tomato nursery"* or *"Heavy rain coming — delay pesticide application by 3 days"*.

**How it works:**
- Weather data: IMD (India Meteorological Department) API + OpenWeatherMap + custom forecast models
- Crop registry: farmer selects current crops and growth stages
- Risk engine maps weather events → crop-specific risk:
  - Rain > 80mm in 24h → flood/waterlogging risk for paddy at tillering stage
  - Temp < 4°C → frost damage risk for wheat, mustard
  - Humidity > 85% + temp 25–30°C → late blight risk for potato
- Alert delivery: push notification + voice alert in local language

**Future scope:**
- Hail prediction integration (Doppler radar data) with advisory to harvest or cover
- Monsoon onset tracker district-wise: sowing window advisory
- Historical climate risk maps: "Your district has had 3 early frost events in Oct in last 10 years — plant frost-tolerant variety"
- Insurance trigger alerts: alerts that also document weather events for PMFBY claim support

---

### 8. 🌱 AI Crop Advisory (Soil + Weather Context)

**What it does:**
Holistic, personalized crop advice that combines soil health data, local weather forecast, crop growth stage, and historical performance — delivered conversationally via voice or text in the farmer's language.

**How it works:**
- Farmer logs: crop, variety, sowing date, irrigation source, soil type
- Sakhi's advisory engine pulls: soil health card data, 14-day weather forecast, pest pressure alerts, growth stage model
- Generates a weekly advisory: what to do this week for this specific crop in this specific field
- Supports 10+ languages via LLM + translation layer (Hindi, Marathi, Punjabi, Telugu, Tamil, Kannada, Bengali, Odia, Gujarati, Malayalam)
- Voice-first: farmer can ask *"Aaj meri fasal mein kya karna chahiye?"* and get a spoken 60-second advisory

**Future scope:**
- Agronomist escalation: if Sakhi is unsure, it routes to a verified agronomist via text/voice for a ₹10–20 paid consult
- Crop calendar generation: full season plan from sowing to harvest with weekly action items
- Comparative advice: "Farmers with similar soil in your block got 18% better yield using split urea application — try this"
- Integration with Digital Crop Survey (DCS) / Bhuvan portal for satellite NDVI crop health monitoring

---

### 9. 📡 Microclimate Farming Sensor Integration

**What it does:**
Sakhi connects to low-cost IoT sensors deployed in the field — soil moisture, temperature, humidity, NPK sensors — and translates real-time sensor data into plain-language farming decisions.

**How it works:**
- Supported sensor types: soil moisture (capacitive), ambient temperature/humidity (DHT22/SHT31), leaf wetness, soil temperature, basic NPK electrochemical sensors
- Connectivity: LoRa (long range, low power — ideal for farms with no cellular) / BLE / WiFi
- Data pipeline: sensor → LoRa gateway (shared among village cluster) → cloud → Sakhi app
- Dashboard: real-time field conditions, daily trends, anomaly alerts
- Decision triggers: "Soil moisture at root zone dropped below 40% FC — irrigate field 2 now"

**Future scope:**
- Ultra-low-cost sensor kits designed for ₹500–1,500 price point, assembled by local SHGs (self-help groups)
- Village-level LoRa gateway network: one gateway per 10km radius serving 100+ farmers
- Automated irrigation integration: Sakhi sends signal to solenoid valve controller to irrigate when threshold is crossed (precision irrigation)
- Microclimate modelling: combine 5 sensor nodes across a farm to map spatial variability — "Apply extra fertilizer in the northeast corner where nutrient levels are lower"
- Carbon credit linkage: verified sensor data on water savings, reduced fertilizer use → carbon credit generation for smallholder farmers

---

## Architecture Principles

| Principle | Detail |
|-----------|--------|
| **Voice-first** | Every feature accessible via voice command in 10+ Indian languages |
| **Offline-first** | Core functionality works without internet; sync when available |
| **Low-data mode** | Designed for 2G/3G; compressed data transfers, progressive loading |
| **Privacy** | Farm data stays on-device by default; cloud sync is opt-in |
| **Interoperability** | Open APIs to connect with eNAM, AgriStack, PMFBY, Soil Health Card portals |
| **Low-literacy UX** | Icon-first UI, audio feedback, minimal text input required |

---

## Tech Stack (Proposed)

| Layer | Stack |
|-------|-------|
| Mobile App | React Native (iOS + Android) |
| On-device AI | TFLite / ONNX Runtime + Whisper-tiny (voice) |
| Backend | Node.js / FastAPI microservices |
| LLM Layer | Claude API (advisory, translation, voice parsing) |
| Weather | IMD API + OpenWeatherMap |
| Market Prices | Agmarknet API + eNAM API |
| IoT | MQTT broker + LoRaWAN + AWS IoT Core |
| Database | PostgreSQL (cloud) + SQLite (on-device) |
| Voice | Whisper (STT) + regional TTS models |

---

## Phased Roadmap

```
Phase 1 (MVP — 6 months)
├── Voice-first crop advisory (Hindi + 2 regional languages)
├── Crop disease image detection (top 20 crops, top 50 diseases)
├── Live mandi price lookup
└── Offline core with background sync

Phase 2 (Growth — 12 months)
├── Fertilizer calculator + soil card integration
├── Government scheme discovery + eligibility engine
├── Crop risk weather alerts
└── Voice marketplace (list & browse produce)

Phase 3 (Scale — 18–24 months)
├── IoT sensor integration + precision irrigation
├── ML price forecasting + inter-mandi arbitrage
├── FPO / aggregation layer for group selling
└── Carbon credit module
```

---

## Impact Potential

- 🇮🇳 **140M+ smallholder farmers** in India — primary audience
- 📉 Reduce post-harvest losses (currently ~16% of crop value) through timely market access
- 💰 Increase farmer income by 15–25% through better price discovery and input optimization
- 🌍 Climate resilience through proactive alerts and microclimate monitoring
- 🤝 Financial inclusion by surfacing government schemes previously invisible to rural farmers

---

*Document version: 0.1 — Internal Ideation*
*Next step: User research sprint with 20 farmers across 3 agro-climatic zones*
