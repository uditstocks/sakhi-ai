from llm_module import generate_text

INTENTS = ["price", "disease", "scheme", "weather", "sos", "general"]


def classify_intent(query: str) -> str:
    sos_keywords = [
        "help", "danger", "unsafe", "scared", "attack",
        "bachao", "madad", "darr", "khatra", "emergency",
        "sos", "save me", "bachao mujhe",
    ]
    query_lower = query.lower()
    if any(word in query_lower for word in sos_keywords):
        return "sos"

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
        intent = generate_text(prompt, temperature=0.1).strip().lower()
        if intent in INTENTS:
            print(f"Intent classified: {intent}")
            return intent
        return "general"
    except Exception as e:
        print(f"Intent classification error: {e}")
        return "general"
