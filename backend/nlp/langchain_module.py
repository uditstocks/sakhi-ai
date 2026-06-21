"""
langchain_module.py — Intent classification module for Sakhi AI.

Classifies farmer queries into intent categories (price, disease, scheme,
weather, sos, general) using the NVIDIA LLM. Uses keyword matching for
SOS detection and LLM-based classification for all other intents.
"""

import os
import sys

# Add backend root to Python path for importing langsmith_setup
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

import langsmith_setup  # noqa: F401
from langsmith import traceable

from nlp.llm_module import generate_text

# All supported intent categories
INTENTS = ["price", "disease", "scheme", "weather", "sos", "general"]

_project = langsmith_setup.LANGSMITH_PROJECT
_trace_tags = ["sakhi-ai", "intent-classifier"]


@traceable(
    name="classify_intent",
    run_type="chain",
    project_name=_project,
    tags=_trace_tags,
)
def classify_intent(query: str) -> str:
    """
    Classifies a farmer's query into one of the supported intent categories.
    Uses keyword matching for SOS detection (fast path), then LLM for all others.

    Args:
        query: The farmer's text query.

    Returns:
        One of: 'price', 'disease', 'scheme', 'weather', 'sos', 'general'.
    """
    # Fast-path SOS detection using keyword matching (no LLM call needed)
    sos_keywords = [
        "help", "danger", "unsafe", "scared", "attack",
        "bachao", "madad", "darr", "khatra", "emergency",
        "sos", "save me", "bachao mujhe",
    ]
    query_lower = query.lower()
    if any(word in query_lower for word in sos_keywords):
        return "sos"

    # LLM-based intent classification prompt
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
        # Use low temperature for deterministic classification
        intent = generate_text(
            prompt,
            temperature=0.1,
            langsmith_extra={"metadata": {"query_preview": query[:200]}},
        ).strip().lower()
        if intent in INTENTS:
            print(f"Intent classified: {intent}")
            return intent
        return "general"
    except Exception as e:
        print(f"Intent classification error: {e}")
        return "general"
