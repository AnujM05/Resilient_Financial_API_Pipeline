# # Resilient Financial Data Pipeline (ETL) & Analytics Engine

## Overview
A production-grade ETL (Extract, Transform, Load) pipeline designed to extract live daily trading data from the Alpha Vantage API, enforce a strict data contract, and securely warehouse the data in a PostgreSQL database. The project features automated retry logic for API resilience, secure credential management, and advanced SQL quantitative analytics for financial signal generation.

## Technical Stack
* **Language:** Python 3.x
* **Database:** PostgreSQL, pgAdmin4
* **Libraries:** `pandas`, `sqlalchemy`, `requests`, `tenacity`, `python-dotenv`
* **Automation:** Windows Task Scheduler, Batch Scripting
* **API:** Alpha Vantage

## Architecture & Implementation

### 1. Resilient Extraction (Phase 1)
Built a highly available API connector to pull daily time-series data for US-listed ADRs (e.g., HDFC Bank).
* **Fault Tolerance:** Implemented the `tenacity` library to build a decorator-driven retry mechanism (3 maximum attempts, 5-second fixed wait) to handle rate limits and server-side timeouts silently.
* **Security:** Enforced strict environmental variable management (`.env`, `.gitignore`) to ensure API keys and database credentials are never hardcoded or exposed to version control.

### 2. Data Transformation & Load (Phase 2)
Engineered a local data warehouse strategy prioritizing data integrity and preventing duplication.
* **Data Formatting:** Utilized `pandas` to flatten nested JSON responses, map data types (floats, bigints), and enforce a standardized schema before database insertion.
* **Idempotent UPSERT Logic:** Designed a custom SQLAlchemy transaction using PostgreSQL's `ON CONFLICT DO UPDATE` constraint. This guarantees pipeline idempotency—updating existing records with fresh data while safely inserting net-new trading days without primary key violations.

### 3. Quantitative SQL Analytics
Transitioned raw warehoused data into actionable financial intelligence using advanced PostgreSQL Window Functions.
* **Trend Analysis (7-Day SMA):** Calculated rolling moving averages using `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW` to smooth daily price actions.
* **Risk Modeling (Intraday Volatility):** Quantified asset risk profiles by calculating the daily percentage spread `((High - Low) / Low)`.
* **Momentum Tracking (DoD Returns):** Leveraged the `LAG()` function to track Day-over-Day percentage returns without resource-heavy self-joins.

### 4. Workflow Automation
Deployed the pipeline as a hands-off, scheduled background task.
* **Execution:** Configured a Windows Batch script (`.bat`) to establish the correct working directory and execute the Python ETL engine.
* **Scheduling:** Integrated with Windows Task Scheduler to run daily post-market close, ensuring the database is continuously updated with zero manual intervention.
