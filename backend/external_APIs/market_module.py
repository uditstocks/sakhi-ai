"""
market_module.py — Mandi (market) price module for Sakhi AI.

Fetches live crop prices from the Indian government's data.gov.in API.
Supports Hindi/English crop name mapping and formats prices for farmer responses.
"""

import requests


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
    try:
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
            "api-key": "REDACTED_API_KEY",
            "format": "json",
            "filters[commodity]": api_crop,
            "filters[state]": state,
            "limit": 5
        }

        response = requests.get(url, params=params, timeout=10)
        data = response.json()

        records = data.get("records", [])
        if not records:
            return f"Aaj {crop} ka mandi price data available nahi hai. Kripya apni najdeeki mandi se confirm karein."

        # Format price data for each market
        result_lines = [f"{crop.capitalize()} ke aaj ke mandi prices ({state}):"]
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