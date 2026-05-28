# Data Warehouse and Analytics Project (PostgreSQL Edition)

Welcome to the **Data Warehouse and Analytics Project** repository 🚀

This project demonstrates a complete end-to-end **Data Warehousing and Analytics solution** built using **PostgreSQL**. The project follows modern **data engineering best practices** including Medallion Architecture, ETL pipeline development, data modeling, and analytical reporting.

> This project was inspired by the **Data Warehouse and Analytics Project** tutorial by **Data With Baraa** on YouTube.
> The original project was implemented using SQL Server, while this version was independently recreated using PostgreSQL and pgAdmin.

---

# 🏗️ Data Architecture

This project follows the **Medallion Architecture** approach using three layers:

## 🥉 Bronze Layer

* Stores raw source data ingested from CSV files
* Data is loaded into PostgreSQL tables without transformations
* Acts as the raw ingestion layer

## 🥈 Silver Layer

* Performs:

  * Data cleansing
  * Standardization
  * Deduplication
  * Data quality checks
* Transforms raw Bronze data into clean analytical datasets

## 🥇 Gold Layer

* Contains business-ready analytical models
* Uses dimensional modeling and star-schema concepts
* Optimized for reporting and analytics

---

# 📖 Project Overview

This project includes:

* Designing a modern data warehouse architecture
* Building ETL pipelines using PostgreSQL stored procedures
* Loading CRM and ERP datasets from CSV files
* Implementing Bronze → Silver → Gold transformations
* Creating analytical views and reporting datasets
* Applying SQL-based data cleansing and transformation techniques

---

# ⚙️ ETL Logging Framework

An additional enhancement implemented in this PostgreSQL version is a custom **ETL logging framework**.

The project includes:

* `etl_log` table for ETL execution monitoring
* Batch-based ETL tracking
* Logging of:

  * ETL stages
  * Procedure execution
  * Table loads
  * Error handling
  * Execution timestamps

This functionality was implemented separately and was not included in the original tutorial project.

---

# 🎯 Skills Demonstrated

This project showcases skills in:

* PostgreSQL Development
* Data Engineering
* ETL Pipeline Development
* Data Warehousing
* Data Modeling
* SQL Analytics
* Window Functions
* Stored Procedures
* Error Handling & Logging
* Data Cleansing & Transformation

---

# 🛠️ Tools & Technologies

* PostgreSQL
* pgAdmin
* SQL
* CSV Datasets
* Git & GitHub
* DrawIO

---

# 🚀 Project Requirements

## Data Engineering

### Objective

Develop a modern data warehouse using PostgreSQL to consolidate CRM and ERP data for analytical reporting and business insights.

### Specifications

* Import data from multiple source systems (CRM & ERP)
* Load CSV datasets into PostgreSQL
* Build ETL pipelines using stored procedures
* Perform data cleansing and transformation
* Integrate data into a unified analytical model
* Implement Medallion Architecture (Bronze, Silver, Gold)
* Add ETL logging and monitoring capabilities

---

# 📊 Analytics & Reporting

### Objective

Generate SQL-based business insights related to:

* Customer Behavior
* Product Performance
* Sales Trends

The final Gold layer is designed to support reporting, analytics, and business decision-making.

---

# 📂 Project Structure

```text
DataWarehouse/
│
├── datasets/
├── scripts/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── etl/
│
├── docs/
└── README.md
```

---

# 🔥 Key PostgreSQL Features Used

* Stored Procedures (`PL/pgSQL`)
* Window Functions (`ROW_NUMBER`, `LAG`)
* Views
* Schemas
* COPY Command
* Exception Handling
* ETL Logging
* Batch Tracking

---

# 📌 Future Improvements

* Automated batch ID generation
* Incremental loading
* Scheduling/orchestration
* Materialized views
* Dashboard integration
* Data quality framework

---

# 🙌 Acknowledgement

Special thanks to **Data With Baraa** for the original SQL Server-based tutorial and project inspiration.

This repository represents an independent PostgreSQL implementation created for learning and portfolio purposes.

