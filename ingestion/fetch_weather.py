import os
import json
import requests
import pandas as pd
from azure.storage.blob import BlobServiceClient
from datetime import datetime, timedelta, timezone

from config import (CITIES, 
                    HOURLY_VARIABLES, 
                    BRONZE_CONTAINER,
                    SILVER_CONTAINER,
                    CACHE_FOLDER_PATH,
                    OPEN_METEO_WEBSITE_URL)


def fetch_weather_for_city(city: dict, date: str) -> dict:
    params = {
        "latitude": city["lat"],
        "longitude": city["lon"],
        "hourly": ",".join(HOURLY_VARIABLES),
        "start_date": date,
        "end_date": date,
        "timezone": "Asia/Kolkata",
        "wind_speed_unit": "kmh",
    }

    response = requests.get(OPEN_METEO_WEBSITE_URL, params=params, timeout=30)
    response.raise_for_status()

    data = response.json()
    data["city_name"] = city["name"]
    data["fetch_date"] = date
    data["fetch_timestamp_utc"] = datetime.now(timezone.utc).isoformat()

    print(f"Fetched: {city['name']}")
    return data


def upload_to_bronze(data: dict, city_name: str, date: str) -> None:
    connection_string = os.environ["AZURE_STORAGE_CONNECTION_STRING"]
    client = BlobServiceClient.from_connection_string(connection_string)

    blob_path = (
        f"weather/{date[:4]}/{date[5:7]}/{date[8:10]}/"
        f"{city_name.lower()}_{date}.json"
    )

    blob_client = client.get_blob_client(
        container=BRONZE_CONTAINER,
        blob=blob_path
    )

    blob_client.upload_blob(json.dumps(data, indent=2), overwrite=True)
    print(f"Uploaded to bronze: {blob_path}")


def transform_to_parquet(df, city_name, date):
    current_timestamp = datetime.now()

    hourly = df["hourly"]

    data = pd.DataFrame({
        "time": hourly["time"],
        "city": [city_name] * len(hourly["time"]),
        "temperature_2m": hourly["temperature_2m"],
        "relative_humidity_2m": hourly["relative_humidity_2m"],
        "precipitation": hourly["precipitation"],
        "wind_speed_10m": hourly["wind_speed_10m"],
        "surface_pressure": hourly["surface_pressure"],
        "cloud_cover": hourly["cloud_cover"],
        "weather_code": hourly["weather_code"],
        "source": ["Open Meteo API"] * len(hourly["time"]),
        "ingestion_timestamp": [current_timestamp] * len(hourly["time"]),
        "observed_date": [date] * len(hourly["time"]),
    })

    os.makedirs(CACHE_FOLDER_PATH, exist_ok=True)

    parquet_file = os.path.join(
        CACHE_FOLDER_PATH,
        f"{city_name.lower()}_{date}.parquet"
    )

    data.to_parquet(parquet_file, index=False)

    connection_string = os.environ["AZURE_STORAGE_CONNECTION_STRING"]
    client = BlobServiceClient.from_connection_string(connection_string)

    blob_path = (
        f"weather/{date[:4]}/{date[5:7]}/{date[8:10]}/"
        f"{city_name.lower()}_{date}.parquet"
    )

    blob_client = client.get_blob_client(
        container=SILVER_CONTAINER,
        blob=blob_path
    )

    with open(parquet_file, "rb") as f:
        blob_client.upload_blob(f, overwrite=True)

    print(f"Uploaded parquet to silver: {blob_path}")

def run_ingestion(date: str | None = None) -> None:
    if date is None:
        date = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")

    print("Weather ingestion started")
    print(f"Date: {date}")

    success_count = 0

    for city in CITIES:
        try:
            data = fetch_weather_for_city(city, date)
            upload_to_bronze(data, city["name"], date)
            transform_to_parquet(data, city['name'], date)
            success_count += 1
        except Exception as e:
            print(f"Failed for {city['name']}: {e}")

    print(f"Ingestion complete: {success_count}/{len(CITIES)} cities")


if __name__ == "__main__":
    run_ingestion()