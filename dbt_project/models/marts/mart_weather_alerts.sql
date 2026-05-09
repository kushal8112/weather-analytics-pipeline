WITH dashboard AS (
    SELECT *
    FROM {{ ref('mart_weather_dashboard') }}
),

alerts AS (
    SELECT
        city,
        observed_date,

        CASE
            WHEN max_temperature_c >= 40 THEN 'HEAT_WAVE'
            WHEN total_precipitation_mm >= 50 THEN 'HEAVY_RAIN'
            WHEN max_wind_speed_kmh >= 60 THEN 'STRONG_WIND'
            WHEN avg_humidity_pct >= 85 THEN 'HIGH_HUMIDITY'
            ELSE NULL
        END AS alert_type,

        CASE
            WHEN max_temperature_c >= 45
              OR total_precipitation_mm >= 100
              OR max_wind_speed_kmh >= 90 THEN 'HIGH'

            WHEN max_temperature_c >= 40
              OR total_precipitation_mm >= 50
              OR max_wind_speed_kmh >= 60
              OR avg_humidity_pct >= 85 THEN 'MEDIUM'

            ELSE 'LOW'
        END AS alert_severity,

        max_temperature_c,
        min_temperature_c,
        avg_temperature_c,
        total_precipitation_mm,
        max_wind_speed_kmh,
        avg_humidity_pct,
        avg_cloud_cover_pct,
        rain_flag,
        hourly_records_count,
        is_complete_day,
        latest_ingestion_timestamp,

        CURRENT_TIMESTAMP AS alert_generated_at

    FROM dashboard
)

SELECT *
FROM alerts
WHERE alert_type IS NOT NULL