import os

# Open Meteo Parameters
CITIES = [
    {"name": "Mumbai", "lat": 19.0760, "lon": 72.8777},
    {"name": "Delhi", "lat": 28.6139, "lon": 77.2090},
    {"name": "Bengaluru", "lat": 12.9716, "lon": 77.5946},
    {"name": "Hyderabad", "lat": 17.3850, "lon": 78.4867},
    {"name": "Chennai", "lat": 13.0827, "lon": 80.2707},
    {"name": "Kolkata", "lat": 22.5726, "lon": 88.3639},
    {"name": "Guwahati", "lat": 26.1445, "lon": 91.7362},
]

HOURLY_VARIABLES = [
    "temperature_2m",
    "relative_humidity_2m",
    "precipitation",
    "wind_speed_10m",
    "surface_pressure",
    "cloud_cover",
    "weather_code",
]

# Azure settings
BRONZE_CONTAINER = "bronze"
SILVER_CONTAINER = "silver"

# Open Meteo settings
OPEN_METEO_WEBSITE_URL = "https://api.open-meteo.com/v1/forecast"

# Folder paths
ROOT_FOLDER = r"C:\Users\anush\OneDrive\Desktop\weather-analytics-pipeline"
CACHE_FOLDER_PATH = os.path.join(ROOT_FOLDER, "cache")