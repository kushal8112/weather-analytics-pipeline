# Weather Analytics Pipeline

[![Python](https://img.shields.io/badge/Python-3.8+-3776ab.svg)](https://www.python.org/)
[![dbt](https://img.shields.io/badge/dbt-1.11.8-FF6849.svg)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/DuckDB-1.5.2-FDB833.svg)](https://duckdb.org/)
[![Azure](https://img.shields.io/badge/Azure-Cloud%20Storage-0078D4.svg)](https://azure.microsoft.com/)

A production-ready data pipeline for ingesting, transforming, and analyzing weather data from multiple Indian cities. Built with a modern data stack leveraging dbt, DuckDB, and Azure Cloud Storage.

## 🎯 Overview

This pipeline orchestrates end-to-end weather data processing across three distinct layers:

- **Bronze Layer**: Raw weather data ingestion from Open-Meteo API → Azure Blob Storage (JSON format)
- **Silver Layer**: Cleaned and transformed data stored as Parquet files in Azure Blob Storage
- **Gold Layer**: Business-ready analytical models with dbt transformations (DuckDB)

### Key Features

✅ **Multi-City Coverage**: Real-time weather data for 7 major Indian cities (Mumbai, Delhi, Bengaluru, Hyderabad, Chennai, Kolkata, Guwahati)  
✅ **Comprehensive Metrics**: Temperature, humidity, precipitation, wind speed, pressure, cloud cover, and weather codes  
✅ **Data Quality Testing**: dbt tests ensuring data integrity and business logic validation  
✅ **Scalable Architecture**: Cloud-native design with Azure Blob Storage for data persistence  
✅ **Analytical Ready**: Pre-built marts for dashboards and alert systems  
✅ **Automated Ingestion**: Python-based ETL with configurable date parameters  

## 📊 Data Architecture

```
Open-Meteo API
      ↓
[Python Ingestion]
      ↓
  Azure Storage (Bronze) ← Raw JSON Files
      ↓
[Data Transformation]
      ↓
  Azure Storage (Silver) ← Parquet Files
      ↓
   [dbt + DuckDB]
      ↓
┌─────────────────┬──────────────────┐
│  Staging Layer  │                  │
│ stg_weather_... │                  │
└────────┬────────┘                  │
         │         ┌─────────────────┘
         ↓         ↓
┌────────────────────────────────────┐
│  Intermediate Layer                │
│ int_weather_daily_summary          │
└────────────┬───────────────────────┘
             ↓
      ┌──────────────────────────┐
      │   Gold/Mart Layer        │
      ├──────────────────────────┤
      │ mart_weather_dashboard   │
      │ mart_weather_alerts      │
      └──────────────────────────┘
```

## 🗂️ Project Structure

```
weather-analytics-pipeline/
├── ingestion/                          # Data ingestion layer
│   ├── config.py                       # Configuration (cities, variables, Azure containers)
│   └── fetch_weather.py                # Main ETL orchestration
├── dbt_project/                        # dbt transformation layer
│   ├── dbt_project.yml                 # dbt project configuration
│   ├── profiles.yml                    # DuckDB connection profile
│   ├── models/
│   │   ├── staging/
│   │   │   ├── sources.yml             # Data source definitions
│   │   │   └── stg_weather_observations.sql    # Cleaned observations
│   │   ├── intermediate/
│   │   │   └── int_weather_daily_summary.sql   # Daily aggregations
│   │   ├── marts/
│   │   │   ├── mart_weather_dashboard.sql      # Business dashboard KPIs
│   │   │   └── mart_weather_alerts.sql         # Extreme weather alerts
│   │   └── schema.yml                  # Data model documentation & tests
│   └── packages.yml                    # dbt package dependencies
├── requirements-dev.txt                # Python dependencies
├── .gitignore                          # Git ignore rules
└── README.md                           # This file
```

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Azure Storage Account with connection string
- DuckDB (included in dependencies)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/kushal8112/weather-analytics-pipeline.git
   cd weather-analytics-pipeline
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements-dev.txt
   ```

4. **Configure Azure credentials**
   ```bash
   export AZURE_STORAGE_CONNECTION_STRING="your_connection_string_here"
   ```

5. **Run the ingestion pipeline**
   ```bash
   cd ingestion
   python fetch_weather.py
   # Optional: specify date as YYYY-MM-DD format
   python fetch_weather.py  # Defaults to yesterday's date
   ```

6. **Execute dbt transformations**
   ```bash
   cd ../dbt_project
   dbt deps
   dbt run
   dbt test
   ```

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| dbt-core | 1.11.8 | Transformation orchestration |
| dbt-duckdb | 1.10.1 | DuckDB adapter for dbt |
| duckdb | 1.5.2 | Columnar analytics database |
| pandas | 3.0.2 | Data manipulation & transformation |
| pyarrow | 24.0.0 | Parquet file format support |
| requests | 2.33.1 | HTTP requests for Open-Meteo API |
| azure-core | 1.40.0 | Azure SDK base library |
| azure-storage-blob | 12.28.0 | Azure Blob Storage client |
| PyYAML | 6.0.3 | YAML parsing |

## 🔄 Data Flow

### Ingestion Phase (`fetch_weather.py`)

1. **API Fetch**: Retrieves hourly weather data from [Open-Meteo API](https://open-meteo.com/) for each city
2. **Bronze Upload**: Stores raw JSON response to Azure Blob Storage (`bronze` container)
3. **Silver Transform**: Converts JSON to Parquet format with structured schema
4. **Silver Upload**: Stores cleaned Parquet files to Azure Blob Storage (`silver` container)

**Supported Hourly Variables:**
- Temperature (2m, °C)
- Relative Humidity (%)
- Precipitation (mm)
- Wind Speed (10m, km/h)
- Surface Pressure (hPa)
- Cloud Cover (%)
- WMO Weather Code

### Transformation Phase (dbt)

#### Staging Layer
**`stg_weather_observations`** - Cleaned hourly weather observations
- Parses and denormalizes Parquet data from Silver layer
- Decodes WMO weather codes into semantic descriptions
- Applies data quality tests (not_null, accepted_values, range validations)
- Output: Columnar view of clean weather observations

#### Intermediate Layer
**`int_weather_daily_summary`** - Daily city-level aggregations
- Aggregates 24 hourly observations per city per day
- Validates data completeness (flags incomplete days)
- Calculates key metrics: min/max/avg temperature, total precipitation
- Output: Daily summary tables for business logic

#### Gold/Mart Layer
**`mart_weather_dashboard`** - Business analytics dashboard
- Daily KPIs with city rankings
- Hottest and wettest city rankings
- Business-ready metrics for BI tools
- Materialized as table for quick access

**`mart_weather_alerts`** - Extreme weather detection
- Identifies and flags extreme weather conditions:
  - **HEAT_WAVE**: Max temp ≥ 35°C
  - **HEAVY_RAIN**: Daily precipitation ≥ 50mm
  - **STRONG_WIND**: Max wind speed ≥ 40 km/h
  - **HIGH_HUMIDITY**: Avg humidity ≥ 80%
- Severity classification (LOW, MEDIUM, HIGH)
- Enables proactive alerting systems

## 📋 Data Quality & Testing

The pipeline implements comprehensive data validation through dbt tests:

```yaml
Tests Implemented:
├── Not Null checks on critical columns
├── Accepted values validation
│   ├── Valid city names
│   ├── Valid weather conditions
│   └── Valid alert severity levels
├── Range validations
│   └── Humidity: 0-100%
├── Data completeness checks
│   └── 24 hourly records per day verification
└── Business logic tests
    ├── Temperature ranges
    ├── Precipitation thresholds
    └── Wind speed validation
```

Run tests:
```bash
dbt test
```

## 🌍 Supported Cities

| City | Latitude | Longitude | Region |
|------|----------|-----------|--------|
| Mumbai | 19.0760 | 72.8777 | Western India |
| Delhi | 28.6139 | 77.2090 | Northern India |
| Bengaluru | 12.9716 | 77.5946 | Southern India |
| Hyderabad | 17.3850 | 78.4867 | South-Central India |
| Chennai | 13.0827 | 80.2707 | Southern India |
| Kolkata | 22.5726 | 88.3639 | Eastern India |
| Guwahati | 26.1445 | 91.7362 | North-Eastern India |

Add or modify cities in `ingestion/config.py`:
```python
CITIES = [
    {"name": "City_Name", "lat": latitude, "lon": longitude},
    # ... additional cities
]
```

## 🔐 Configuration

### Environment Variables

```bash
# Required
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=...

# Optional (dbt)
DBT_PROFILES_DIR=./dbt_project
```

### Azure Storage Setup

1. Create two containers in your Azure Storage Account:
   - `bronze` - Raw data storage
   - `silver` - Cleaned data storage

2. Update container names in `ingestion/config.py`:
   ```python
   BRONZE_CONTAINER = "bronze"
   SILVER_CONTAINER = "silver"
   ```

## 📈 Usage Examples

### Run Full Pipeline for Specific Date

```bash
cd ingestion
python fetch_weather.py "2026-05-08"
```

### Run dbt Transformations Only

```bash
cd dbt_project
dbt run --models staging    # Run only staging models
dbt run --models marts      # Run only mart models
dbt run --selector tag:daily  # Run models with 'daily' tag
```

### Run Data Quality Tests

```bash
dbt test                    # Test all models
dbt test --models stg_*     # Test staging models
dbt test --fail-fast        # Stop on first failure
```

### Generate dbt Documentation

```bash
dbt docs generate
dbt docs serve              # Opens documentation on http://localhost:8000
```

### Query Results with DuckDB

```python
import duckdb

conn = duckdb.connect("dbt_project/weather_analytics.duckdb")
result = conn.execute("""
    SELECT city, observed_date, hottest_city_rank_for_day
    FROM mart_weather_dashboard
    WHERE observed_date >= '2026-05-01'
    ORDER BY observed_date DESC
""").fetchall()

for row in result:
    print(row)
```

## 🛠️ Development Workflow

### Adding a New Model

1. Create SQL file in appropriate layer (staging/intermediate/marts)
2. Add documentation to `models/schema.yml`
3. Implement data quality tests
4. Run `dbt run` to build
5. Run `dbt test` to validate

### Modifying Data Transformations

```bash
# Test changes locally
dbt run --models model_name --select +model_name+

# Run full test suite
dbt test

# Generate lineage visualization
dbt docs generate && dbt docs serve
```

## 📊 Performance Considerations

- **Materialization Strategy**:
  - Staging: `view` (lightweight, always fresh)
  - Intermediate: `table` (intermediate aggregations)
  - Marts: `table` (optimized for queries)

- **Optimization Tips**:
  - DuckDB is optimized for analytical queries over columnar data
  - Parquet format provides compression and efficient storage
  - Azure Blob Storage scales for large datasets
  - Partition data by date for faster queries

## 🐛 Troubleshooting

### Azure Connection Issues
```bash
# Verify connection string
echo $AZURE_STORAGE_CONNECTION_STRING

# Test connection
python -c "from azure.storage.blob import BlobServiceClient; client = BlobServiceClient.from_connection_string(...)"
```

### dbt Build Failures
```bash
# Check profiles configuration
dbt debug

# Run with verbose output
dbt run --debug

# Clear artifacts and rebuild
rm -rf dbt_project/target dbt_project/dbt_packages
dbt deps && dbt run
```

### Missing Data in Marts
```bash
# Verify staging data loaded correctly
dbt test --models stg_weather_observations

# Check intermediate aggregations
SELECT * FROM int_weather_daily_summary LIMIT 5;
```

## 📚 Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [DuckDB Guide](https://duckdb.org/docs/)
- [Open-Meteo API Reference](https://open-meteo.com/en/docs)
- [Azure Blob Storage Documentation](https://learn.microsoft.com/en-us/azure/storage/blobs/)
- [WMO Weather Code Reference](https://www.weatherapi.com/docs/weather_codes.json)

## 🤝 Contributing

Contributions are welcome! Please ensure:

1. All dbt tests pass (`dbt test`)
2. Code follows project conventions
3. Documentation is updated
4. New models include schema.yml entries

## 📄 License

This project is open source and available under the MIT License.

## 👤 Author

**Kushal**
- GitHub: [@kushal8112](https://github.com/kushal8112)

---

**Last Updated**: May 2026

For questions or support, please open an issue on the [GitHub repository](https://github.com/kushal8112/weather-analytics-pipeline/issues).
