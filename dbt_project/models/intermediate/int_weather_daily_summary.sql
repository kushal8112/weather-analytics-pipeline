SELECT 
    city,
    observed_date,

    AVG(temperature_c) AS avg_temperature_c,
    MAX(temperature_c) AS max_temperature_c,
    MIN(temperature_c) AS min_temperature_c,
    MAX(temperature_c) - MIN(temperature_c) AS temperature_range_c,

    AVG(relative_humidity_pct) AS avg_humidity_pct,
    MAX(relative_humidity_pct) AS max_humidity_pct,
    MIN(relative_humidity_pct) AS min_humidity_pct,

    SUM(precipitation_mm) AS total_precipitation_mm,

    SUM(
        CASE 
            WHEN precipitation_mm > 0 THEN 1 
            ELSE 0 
        END
    ) AS rainy_hours,

    CASE 
        WHEN SUM(CASE WHEN precipitation_mm > 0 THEN 1 ELSE 0 END) > 0 
        THEN 1 
        ELSE 0 
    END AS rain_flag,

    AVG(wind_speed_kmh) AS avg_wind_speed_kmh,
    MAX(wind_speed_kmh) AS max_wind_speed_kmh,

    AVG(surface_pressure_hpa) AS avg_pressure_hpa,
    AVG(cloud_cover_pct) AS avg_cloud_cover_pct,

    COUNT(observed_at) AS hourly_records_count,

    MAX(ingestion_timestamp) AS latest_ingestion_timestamp,

    CASE 
        WHEN COUNT(observed_at) = 24 THEN 1 
        ELSE 0 
    END AS is_complete_day,

    CURRENT_TIMESTAMP AS model_run_timestamp

FROM {{ ref('stg_weather_observations') }}

GROUP BY 
    city,
    observed_date