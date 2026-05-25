import requests
import os
from dotenv import load_dotenv

load_dotenv()

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")

def get_weather(location: str = "Lucknow") -> str:
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

        temp = data["main"]["temp"]
        humidity = data["main"]["humidity"]
        description = data["weather"][0]["description"]
        wind_speed = data["wind"]["speed"]
        feels_like = data["main"]["feels_like"]

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
    desc_lower = description.lower()

    if "rain" in desc_lower or "drizzle" in desc_lower:
        return "Aaj barish ho rahi hai. Spray mat karein, khet mein pani nikalne ka intezam karein."
    elif "storm" in desc_lower or "thunder" in desc_lower:
        return "Aandhi toofan ka khatra hai. Khet mein mat jayein, surakshit rahein."
    elif temp > 40:
        return "Bahut garmi hai. Seedling ko dhoop se bachayein, subah ya shaam ko sinchai karein."
    elif temp < 10:
        return "Thandi bahut hai. Rabi fasal ke liye achha hai. Pala padne ka khatra ho to dhuan karein."
    elif humidity > 80:
        return "Naami zyada hai. Fungal bimari ka khatra badh sakta hai. Fasal ki niyamit nigrani karein."
    elif "clear" in desc_lower and temp >= 20 and temp <= 35:
        return "Mausam kheti ke liye achha hai. Spray aur sinchai ke liye sahi din hai."
    else:
        return "Mausam theek hai. Niyamit kheti ka kaam jaari rakhein."