# Resilient Financial Data Pipeline (ETL) & Analytics Engine

## 📌 The Business Problem
Financial analysts and quantitative researchers require reliable, daily market data to generate trading signals and assess risk. However, standard third-party API pipelines are inherently fragile—crashing during server timeouts, failing on rate limits, or creating catastrophic duplicate records if executed twice. This unreliability forces data engineers to manually babysit data extraction, delaying critical financial intelligence.

This project is an automated, production-grade ETL (Extract, Transform, Load) pipeline built to solve these exact issues. It ensures fault-tolerant data ingestion, enforces strict schema contracts, prevents database duplication, and automatically generates quantitative trading signals.

## 🛠️ Tech Stack
* **Data Extraction (API):** Python (Requests, `tenacity` for automated retry logic)
* **Data Transformation:** Python (Pandas)
* **Data Warehousing:** PostgreSQL, SQLAlchemy
* **Data Analytics:** Advanced SQL (Window Functions, LAG, Rolling Averages)
* **Pipeline Automation:** Windows Task Scheduler, Batch Scripting
* **Security:** `python-dotenv` for local credential isolation

## ⚙️ The Pipeline Architecture

### 1. Resilient API Extraction (The Fault-Tolerant Engine)
To prevent the pipeline from crashing due to transient network drops or Alpha Vantage API rate limits, I engineered a highly available Python extraction script. Utilizing the `tenacity` library, I implemented a decorator-driven retry mechanism. If the server hangs or drops the connection, the pipeline automatically pauses for a fixed 5-second interval and attempts up to 3 automated retries before failing gracefully. 

### 2. The Data Contract (Schema Normalization)
Raw API data returns as unstructured, nested JSON with numeric values serialized as strings. Before warehousing, the data passes through a Pandas-driven transformation function. This flattens the JSON, maps the columns to standard snake_case, and enforces rigid datatypes (casting monetary values to strict floats and standardizing timestamps). This guarantees the downstream PostgreSQL database is protected from fatal type-casting errors.

### 3. Idempotent Data Warehousing (Zero Duplication)
To solve the industry-wide problem of duplicate data ingestion, I engineered an idempotent transaction block using SQLAlchemy. I leveraged PostgreSQL’s `ON CONFLICT DO UPDATE` (UPSERT) constraint on a composite primary key (`trade_date`, `symbol`). This guarantees that running the pipeline multiple times a day will safely update existing records with the latest data while inserting new trading days, completely preventing primary key violations.

### 4. Quantitative SQL Analytics 
Once warehoused, the raw price data is processed by a secondary PostgreSQL analytics engine using advanced Window Functions to extract immediate financial intelligence:
* **Trend Analysis (7-Day SMA):** Utilized `AVG() OVER (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)` to create rolling moving averages, smoothing daily price actions to identify macro trends.
* **Risk Modeling (Intraday Volatility):** Engineered a daily volatility calculation `((High - Low) / Low)` to flag aggressive intraday price swings.
* **Momentum Tracking (DoD Returns):** Leveraged the `LAG()` function to dynamically calculate exact Day-over-Day percentage returns without resource-heavy self-joins.

### 5. Workflow Automation
To achieve a "hands-off" production state, I wrapped the Python execution logic into a lightweight Windows Batch script (`.bat`). This was integrated directly into Windows Task Scheduler, orchestrating the pipeline to run silently in the background every evening at 6:00 PM after the US financial markets close.

## 🚀 Business Impact
This architecture successfully automates the daily ingestion of market data with 100% reliability and zero data duplication. By shifting from manual extraction to automated fault tolerance, it guarantees continuous data flow. Furthermore, the SQL analytics engine successfully transitioned raw data into actionable insights—such as automatically flagging a massive 5.68% intraday volatility anomaly during the September 11 trading session—proving its immediate value for institutional research.

## 💼 Financial Mechanics & Operational Handoff
To bridge the gap between backend data engineering and frontend financial operations, this architecture is designed to hand off specific data models to business users.

### 1. The Business Context
In institutional finance, quantitative analysts rely on clean, uninterrupted historical data to assess asset risk and momentum. An ETL pipeline must deliver this data reliably before the next trading day begins. 

### 2. The Metrics Translated
* **7-Day SMA (Trend):** Used by traders to determine if an asset is in a broader uptrend or downtrend, ignoring daily noise.
* **Intraday Volatility (Risk):** Used by risk managers to assess the spread of the asset; higher volatility indicates higher risk and potential for algorithmic stop-loss triggers.
* **DoD Returns (Momentum):** Used by portfolio managers to track daily asset performance and momentum shifts.

### 3. Departmental Workflow (The Handoff)
* **Data Engineering (My Role):** Maintains the zero-touch automated Python pipeline, monitors the `.bat` execution logs, and ensures the API retry logic scales with external vendor limits.
* **Quantitative Analysts / Trading Desk:** Consume the materialized SQL views generated by the analytics engine to build trading algorithms, risk dashboards, and investment thesis reports.
