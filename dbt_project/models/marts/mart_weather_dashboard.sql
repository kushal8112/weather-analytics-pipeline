WITH daily AS (
    SELECT *
    FROM {{ ref('int_weather_daily_summary') }}
),

final AS (
    SELECT
        city,
        observed_date,

        avg_temperature_c,
        max_temperature_c,
        min_temperature_c,
        temperature_range_c,

        avg_humidity_pct,
        max_humidity_pct,
        min_humidity_pct,

        total_precipitation_mm,
        rainy_hours,
        rain_flag,

        avg_wind_speed_kmh,
        max_wind_speed_kmh,

        avg_pressure_hpa,
        avg_cloud_cover_pct,

        hourly_records_count,
        is_complete_day,
        latest_ingestion_timestamp,

        RANK() OVER (
            PARTITION BY observed_date
            ORDER BY max_temperature_c DESC
        ) AS hottest_city_rank_for_day,

        RANK() OVER (
            PARTITION BY observed_date
            ORDER BY total_precipitation_mm DESC
        ) AS wettest_city_rank_for_day,

        avg_temperature_c
        - LAG(avg_temperature_c) OVER (
            PARTITION BY city
            ORDER BY observed_date
        ) AS temperature_change_from_previous_day_c,

        AVG(avg_temperature_c) OVER (
            PARTITION BY city
            ORDER BY observed_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS rolling_7_day_avg_temperature_c,

        AVG(avg_temperature_c) OVER (
            PARTITION BY city, EXTRACT(YEAR FROM observed_date), EXTRACT(MONTH FROM observed_date)
            ORDER BY observed_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS month_to_date_avg_temperature_c,

        SUM(total_precipitation_mm) OVER (
            PARTITION BY city, EXTRACT(YEAR FROM observed_date), EXTRACT(MONTH FROM observed_date)
            ORDER BY observed_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS month_to_date_total_precipitation_mm,

        CURRENT_TIMESTAMP AS model_run_timestamp

    FROM daily
)

SELECT *
FROM final