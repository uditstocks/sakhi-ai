"""
market_module.py — Mandi (market) price module for Sakhi AI.

Fetches live crop prices from the Indian government's data.gov.in API.
Supports Hindi/English crop name mapping and formats prices for farmer responses.
"""

import os
import sys

import requests
from dotenv import load_dotenv

# Load .env from backend root so the API key is read from the environment,
# never hard-coded in source.
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)
load_dotenv(os.path.join(_backend_root, ".env"))

DATA_GOV_API_KEY = os.getenv("DATA_GOV_API_KEY")

# data.gov.in filters on full state names. The frontend (and the /mandi route)
# may pass either a short code ("UP") or a full name ("Uttar Pradesh"); map both
# to the canonical name the API expects.
STATE_NAME_MAP = {
    "up": "Uttar Pradesh",
    "uttar pradesh": "Uttar Pradesh",
    "mh": "Maharashtra",
    "maharashtra": "Maharashtra",
    "pb": "Punjab",
    "punjab": "Punjab",
    "hr": "Haryana",
    "haryana": "Haryana",
    "br": "Bihar",
    "bihar": "Bihar",
    "rj": "Rajasthan",
    "rajasthan": "Rajasthan",
    "mp": "Madhya Pradesh",
    "madhya pradesh": "Madhya Pradesh",
    "gj": "Gujarat",
    "gujarat": "Gujarat",
}


def _canonical_state(state: str) -> str:
    """Maps a state code or name to the canonical full name the API expects."""
    return STATE_NAME_MAP.get(state.strip().lower(), state.strip())


def get_mandi_price(crop: str, state: str = "Uttar Pradesh") -> str:
    """
    Fetches current mandi (market) prices for a given crop from the government API.

    Args:
        crop: Crop name in English or Hindi (e.g., 'wheat', 'gehoon', 'rice').
        state: Indian state name. Defaults to 'Uttar Pradesh'.

    Returns:
        Formatted string with market prices (min, max, modal) per quintal,
        or a message if data is unavailable.
    """
    if not DATA_GOV_API_KEY:
        print("Mandi price error: DATA_GOV_API_KEY is not set in .env")
        return "Mandi price service abhi configure nahi hai. Baad mein try karein."

    try:
        canonical_state = _canonical_state(state)

        # Maps Hindi/English crop names to API-compatible names
        crop_map = {
            "wheat": "Wheat", "gehoon": "Wheat", "gehun": "Wheat",
            "rice": "Paddy(Dhan)(Common)", "chawal": "Paddy(Dhan)(Common)", "dhan": "Paddy(Dhan)(Common)",
            "cotton": "Cotton", "kapas": "Cotton",
            "maize": "Maize", "makka": "Maize",
            "onion": "Onion", "pyaaz": "Onion",
            "potato": "Potato", "aloo": "Potato",
            "tomato": "Tomato", "tamatar": "Tomato",
        }

        # Normalize crop name to API format
        crop_key = crop.lower().strip()
        api_crop = crop_map.get(crop_key, crop.capitalize())

        # Fetch prices from data.gov.in API
        url = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
        params = {
            "api-key": DATA_GOV_API_KEY,
            "format": "json",
            "filters[commodity]": api_crop,
            "filters[state]": canonical_state,
            "limit": 5
        }

        response = requests.get(url, params=params, timeout=10)
        data = response.json()

        records = data.get("records", [])
        if not records:
            return f"Aaj {crop} ka mandi price data available nahi hai. Kripya apni najdeeki mandi se confirm karein."

        # Format price data for each market
        result_lines = [f"{crop.capitalize()} ke aaj ke mandi prices ({canonical_state}):"]
        for r in records:
            market = r.get("market", "Unknown")
            modal_price = r.get("modal_price", "N/A")
            min_price = r.get("min_price", "N/A")
            max_price = r.get("max_price", "N/A")
            result_lines.append(
                f"- {market}: Min Rs.{min_price}, Max Rs.{max_price}, Modal Rs.{modal_price} per quintal"
            )

        return "\n".join(result_lines)

    except Exception as e:
        print(f"Mandi price error: {e}")
        return f"Mandi price abhi fetch nahi ho saka. Baad mein try karein."