"""
weather_module.py — Weather module for Sakhi AI.

Fetches real-time weather data from OpenWeatherMap API and provides
farming-specific advice based on temperature, humidity, and conditions.
"""

import requests
import os
import sys
from dotenv import load_dotenv

# Add backend root to Python path
_backend_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _backend_root)

# Load .env from backend root directory
dotenv_path = os.path.join(_backend_root, ".env")
load_dotenv(dotenv_path)

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")


def get_weather(location: str = "Lucknow") -> str:
    """
    Fetches current weather data for a given location from OpenWeatherMap.

    Args:
        location: City name in India. Defaults to 'Lucknow'.

    Returns:
        Formatted weather string with temperature, humidity, wind, and farming advice.
        Returns error message if data is unavailable.
    """
    try:
        url = "https://api.openweathermap.org/data/2.5/weather"
        params = {
            "q": f"{location},IN",
            "appid": OPENWEATHER_API_KEY,
            "units": "metric",
            "lang": "hi"
        }

        response = requests.get(url, params=params, timeout=10)
        data = response.json()

        if data.get("cod") != 200:
            return f"{location} ka weather data abhi available nahi hai."

        # Extract weather metrics from API response
        temp = data["main"]["temp"]
        humidity = data["main"]["humidity"]
        description = data["weather"][0]["description"]
        wind_speed = data["wind"]["speed"]
        feels_like = data["main"]["feels_like"]

        # Get farming-specific advice based on conditions
        advice = get_farming_advice(temp, humidity, description)

        return (
            f"{location} ka aaj ka mausam:\n"
            f"Taapman: {temp}°C (feels like {feels_like}°C)\n"
            f"Aasmaani: {description}\n"
            f"Naami: {humidity}%\n"
            f"Hawa ki raftaar: {wind_speed} m/s\n\n"
            f"Kheti salah: {advice}"
        )

    except Exception as e:
        print(f"Weather error: {e}")
        return "Mausam ki jaankari abhi fetch nahi ho saki. Baad mein try karein."


def get_farming_advice(temp: float, humidity: int, description: str) -> str:
    """
    Generates farming advice based on current weather conditions.

    Args:
        temp: Temperature in Celsius.
        humidity: Humidity percentage.
        description: Weather description (e.g., 'clear sky', 'light rain').

    Returns:
        A farming advice string in Hindi/Hinglish.
    """
    desc_lower = description.lower()

    # Rain conditions — avoid spraying, manage water
    if "rain" in desc_lower or "drizzle" in desc_lower:
        return "Aaj barish ho rahi hai. Spray mat karein, khet mein pani nikalne ka intezam karein."
    # Storm conditions — safety warning
    elif "storm" in desc_lower or "thunder" in desc_lower:
        return "Aandhi toofan ka khatra hai. Khet mein mat jayein, surakshit rahein."
    # Extreme heat — protect seedlings
    elif temp > 40:
        return "Bahut garmi hai. Seedling ko dhoop se bachayein, subah ya shaam ko sinchai karein."
    # Extreme cold — frost warning
    elif temp < 10:
        return "Thandi bahut hai. Rabi fasal ke liye achha hai. Pala padne ka khatra ho to dhuan karein."
    # High humidity — fungal disease risk
    elif humidity > 80:
        return "Naami zyada hai. Fungal bimari ka khatra badh sakta hai. Fasal ki niyamit nigrani karein."
    # Ideal conditions — good for farming activities
    elif "clear" in desc_lower and temp >= 20 and temp <= 35:
        return "Mausam kheti ke liye achha hai. Spray aur sinchai ke liye sahi din hai."
    else:
        return "Mausam theek hai. Niyamit kheti ka kaam jaari rakhein."