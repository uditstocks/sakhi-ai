import os
from dotenv import load_dotenv
from google import genai

module_dir = os.path.dirname(os.path.abspath(__file__))
dotenv_path = os.path.join(module_dir, ".env")
load_dotenv(dotenv_path)

api_key = os.getenv("GEMINI_API_KEY")
client = genai.Client(api_key=api_key)

INTENTS = ["price", "disease", "scheme", "weather", "sos", "general"]

def classify_intent(query: str) -> str:
    
    # SOS check first — highest priority, no AI needed
    sos_keywords = [
        "help", "danger", "unsafe", "scared", "attack",
        "bachao", "madad", "darr", "khatra", "emergency",
        "sos", "save me", "bachao mujhe"
    ]
    query_lower = query.lower()
    if any(word in query_lower for word in sos_keywords):
        return "sos"

    # Use Gemini to classify everything else
    prompt = f"""
You are an intent classifier for an agricultural assistant app for Indian farmers.

Classify the following query into exactly ONE of these intents:
- price: asking about crop prices, mandi rates, when to sell, market rates
- disease: asking about crop disease, pests, leaf problems, plant health, symptoms
- scheme: asking about government schemes, subsidies, PM-KISAN, PMFBY, benefits
- weather: asking about weather, rain, temperature, forecast
- sos: expressing danger, fear, emergency, needing help urgently
- general: anything else related to farming

Query: "{query}"

Reply with ONLY one word from this list: price, disease, scheme, weather, sos, general
No explanation. No punctuation. Just the single word.
"""

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt
        )
        intent = response.text.strip().lower()
        if intent in INTENTS:
            print(f"Intent classified: {intent}")
            return intent
        return "general"
    except Exception as e:
        print(f"Intent classification error: {e}")
        return "general"