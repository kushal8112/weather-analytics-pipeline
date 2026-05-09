SELECT
    city,

    CAST(temperature_2m AS DOUBLE) AS temperature_c,
    CAST(relative_humidity_2m AS DOUBLE) AS relative_humidity_pct,
    COALESCE(CAST(precipitation AS DOUBLE), 0) AS precipitation_mm,
    CAST(wind_speed_10m AS DOUBLE) AS wind_speed_kmh,
    CAST(surface_pressure AS DOUBLE) AS surface_pressure_hpa,
    CAST(cloud_cover AS DOUBLE) AS cloud_cover_pct,
    CAST(weather_code AS INTEGER) AS weather_code_wmo,

    source,
    CAST(ingestion_timestamp AS TIMESTAMP) AS ingestion_timestamp,

    CAST(time AS TIMESTAMP) AS observed_at,
    CAST(time AS DATE) AS observed_date,
    EXTRACT(HOUR FROM CAST(time AS TIMESTAMP)) AS observed_hour,

    CASE
        WHEN temperature_2m IS NULL THEN 'unknown'
        WHEN CAST(temperature_2m AS DOUBLE) < 20 THEN 'cool'
        WHEN CAST(temperature_2m AS DOUBLE) >= 20
             AND CAST(temperature_2m AS DOUBLE) < 30 THEN 'pleasant'
        WHEN CAST(temperature_2m AS DOUBLE) >= 30
             AND CAST(temperature_2m AS DOUBLE) < 38 THEN 'hot'
        ELSE 'very_hot'
    END AS temperature_category,

    CASE
        WHEN precipitation IS NULL THEN 'unknown'
        WHEN CAST(precipitation AS DOUBLE) = 0 THEN 'no_rain'
        WHEN CAST(precipitation AS DOUBLE) > 0
             AND CAST(precipitation AS DOUBLE) < 2.5 THEN 'light_rain'
        WHEN CAST(precipitation AS DOUBLE) >= 2.5
             AND CAST(precipitation AS DOUBLE) < 10 THEN 'moderate_rain'
        ELSE 'heavy_rain'
    END AS precipitation_category,

    CASE
        WHEN weather_code IS NULL THEN 'unknown'
        WHEN CAST(weather_code AS INTEGER) = 0 THEN 'clear'
        WHEN CAST(weather_code AS INTEGER) BETWEEN 1 AND 3 THEN 'cloudy'
        WHEN CAST(weather_code AS INTEGER) BETWEEN 45 AND 48 THEN 'fog'
        WHEN CAST(weather_code AS INTEGER) BETWEEN 51 AND 67 THEN 'rain'
        WHEN CAST(weather_code AS INTEGER) BETWEEN 80 AND 82 THEN 'rain_showers'
        WHEN CAST(weather_code AS INTEGER) BETWEEN 95 AND 99 THEN 'thunderstorm'
        ELSE 'unknown'
    END AS weather_description,

    CURRENT_TIMESTAMP AS model_run_timestamp

FROM read_parquet('../cache/*.parquet')

WHERE city IS NOT NULL
  AND time IS NOT NULL