# "NYC Collision Multi-Layer Geospatial Intelligence Analytics"

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.9%2B-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13%2B-blue.svg)](https://www.postgresql.org/)
[![PostGIS](https://img.shields.io/badge/PostGIS-3.0%2B-green.svg)](https://postgis.net/)

An end-to-end analytics pipeline for New York City's Motor Vehicle Collision data — from raw, messy CSV to a fully normalized (3NF) PostgreSQL database, SQL-driven analytics, and interactive spatial visualizations. The project mirrors how a real banking/analytics data pipeline is built: clean once in Pandas, model and query at scale in SQL, and visualize only the aggregated results in Python.

## 🗺️ Interactive Spatial Analysis

Explore the interactive maps directly in your browser:

- [📍 Collision Location Heatmap](https://pradhumansoni.github.io/nyc-vehicle-collision-spatial-analytics/collision_location_heatmap.html)
- [🗺️ ZIP Code Collision Choropleth](https://pradhumansoni.github.io/nyc-vehicle-collision-spatial-analytics/zip_collision_choropleth.html)
- [🏙️ Borough Collision Choropleth](https://pradhumansoni.github.io/nyc-vehicle-collision-spatial-analytics/borough_collision_choropleth.html)

- 
---

## 📌 Table of Contents
- [Project Overview](#-project-overview)
- [Problem Statement](#-problem-statement)
- [Key Features](#-key-features)
- [Methodology](#-methodology)
- [Database Design](#-database-design)
- [SQL Analytics — 11 Key Questions](#-sql-analytics--11-key-questions)
- [Spatial Analysis](#-spatial-analysis)
- [Key Insights](#-key-insights)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Design Decisions & Scope Cuts](#-design-decisions--scope-cuts)
- [How to Contribute](#-how-to-contribute)
- [Contact](#-contact)
- [License](#-license)

---

## 🌍 Project Overview

This project takes the raw **NYC Motor Vehicle Collisions** dataset — a large, inconsistent, real-world CSV — and turns it into a queryable, analysis-ready system. Rather than doing everything in Pandas or forcing a data-warehouse architecture onto a project that didn't need one, the pipeline deliberately splits responsibilities:

- **Pandas** handles row-level, messy cleaning (types, missing values, invalid coordinates, malformed categorical fields).
- **PostgreSQL** handles structural modeling, normalization, and heavy aggregation.
- **PostGIS** handles the geographic layer — heatmaps and choropleths at three different spatial granularities.
- **Python (Plotly)** is used only at the very end, to visualize small, already-aggregated result sets.

The result is a lean, production-style ETL → SQL analytics → spatial visualization workflow, rather than an over-engineered warehouse for a dataset that didn't call for one.

---

## 🎯 Problem Statement

NYC's collision data is large, repetitive (up to 5 vehicles and 5 contributing factors per crash, stored as flat repeating columns), and geographically inconsistent (latitude/longitude, ZIP code, and borough are recorded independently and don't always agree). Used naively, this leads to double-counting, broken joins, and misleading maps. This project aims to answer:

- How do collisions vary over time — by year, month, day of week, and hour?
- Which boroughs see the most collisions, injuries, and fatalities?
- What are the most common contributing factors and vehicle types involved in collisions?
- Where are the physical collision hotspots, and how does that differ from ZIP-level or borough-level aggregation?
- How should a repeating, denormalized schema like this actually be modeled in a relational database?

---

## ✨ Key Features

- **Profile-First Schema Design**: The 3NF schema was derived *from* the data (dependencies, repeating groups, cardinality) rather than designed upfront and forced onto it.
- **Proper Handling of Repeating Fields**: `VEHICLE TYPE CODE 1–5` and `CONTRIBUTING FACTOR VEHICLE 1–5` are normalized into their own tables — without assuming vehicle *n* corresponds to factor *n*.
- **Analytical View Layer**: A single `analytics.vw_collision_analysis` view exposes clean, derived temporal fields (`crash_year`, `crash_hour`, `is_weekend`, `time_of_day`, etc.) so every downstream query works off one consistent interface.
- **SQL-First Aggregation**: All heavy lifting (grouping, counting, ratios) happens in PostgreSQL — Python only touches small, already-aggregated result sets.
- **Three-Layer Spatial Analysis**: Point-level (lat/long), ZIP-level, and borough-level geography are treated as three genuinely different representations, not interchangeable proxies for "location."

---

## 🛠️ Methodology

#### Environment & Infrastructure
- Project repository set up with Git/GitHub and a dedicated Python environment.
- **Docker + PostgreSQL + PostGIS** used for the database layer.
- `nyc_collisions` PostgreSQL database created and connectivity verified.
- Connected VS Code/Jupyter to PostgreSQL via **SQLAlchemy + psycopg2**.

#### Pandas — Row-Level Cleaning
- Investigated dataset structure: columns, data types, missing values, cardinality, duplicates, locations, vehicle types, and contributing factors.
- Converted columns to appropriate types and standardized text/category values.
- Investigated and handled missing values.
- Validated latitude/longitude and removed records unusable for location-based analysis.
- Cleaned vehicle-type and contributing-factor fields.
- Exported a cleaned CSV — the **raw source CSV was never modified**.

#### PostgreSQL — Staging & Investigation
- Loaded the cleaned CSV into a staging table: `staging.cleaned_collisions`.
- Investigated the data *in SQL* before designing the schema: duplicate `collision_id`s, cardinality, NULL distributions, vehicle/factor variations, geographic attributes, repeating groups, and functional dependencies.

The guiding design principle:

```
Actual Dataset → Profile → Understand Dependencies →
Identify Repeating Groups → Design 3NF
```

rather than inventing a schema beforehand.

---

## 🗄️ Database Design

The normalized schema (`normalized` schema):

```
normalized
│
├── collisions            # one row per collision, core attributes
├── vehicle_types          # lookup of distinct vehicle types
├── collision_vehicles     # normalized VEHICLE TYPE CODE 1–5
├── contributing_factors   # lookup of distinct contributing factors
└── collision_factors      # normalized CONTRIBUTING FACTOR VEHICLE 1–5
```

The original vehicle/factor sequence was preserved during normalization — vehicle 1 was **not** assumed to correspond to factor 1, since the source data doesn't guarantee that alignment.

On top of this, an analytical view was built:

```sql
analytics.vw_collision_analysis
```

which derives temporal attributes used throughout the analysis: `crash_year`, `crash_month`, `crash_month_name`, `crash_day`, `crash_day_of_week`, `crash_day_name`, `crash_week`, `crash_hour`, `is_weekend`, `time_of_day`.

---

## 📊 SQL Analytics — 11 Key Questions

All analytics were run against `analytics.vw_collision_analysis` directly in PostgreSQL, keeping the questions deliberately focused rather than sprawling:

1. Collisions by year
2. Collisions by month
3. Collisions by time of day
4. Collisions by hour
5. Weekday vs. weekend collisions
6. Collisions by borough
7. Injuries and fatalities by borough
8. Collision severity distribution
9. Most common contributing factors
10. Most common vehicle types
11. Vehicle types by borough

Only the resulting (small) query outputs were pulled into Python, using **Pandas** to consume the SQL results and **Plotly** to render all 11 visualizations, exported as PNGs to `outputs/analytics/`.

---

## 🌐 Spatial Analysis

Collision geography was analyzed at three distinct, deliberately separate granularities — since coordinates, ZIP codes, and boroughs are recorded independently in the source data and shouldn't be treated as interchangeable:

| Layer | Geographic Basis | Output |
|---|---|---|
| **Location** | Recorded latitude/longitude | Collision hotspot heatmap |
| **ZIP** | Recorded ZIP code + official ZIP polygons | ZIP-level collision choropleth |
| **Borough** | Recorded borough + borough polygons | Borough-level collision choropleth |

Each was saved as its own interactive HTML file rather than combined into a single overloaded map:

```
outputs/
└── spatial/
    ├── collision_location_heatmap.html
    ├── zip_collision_choropleth.html
    └── borough_collision_choropleth.html
```

---

## 📊 Key Insights

*(Fill in with your actual query results — placeholders below based on typical NYC collision patterns; replace with your real numbers before publishing.)*

- **Temporal Concentration**: Collisions peak during weekday evening rush hours, with a visible drop during weekend early mornings.
- **Borough Disparity**: Brooklyn and Queens consistently report the highest raw collision counts, though injury/fatality *rates* tell a different story once normalized.
- **Dominant Contributing Factor**: Driver inattention/distraction dominates recorded contributing factors by a wide margin over mechanical or environmental causes.
- **Vehicle Type Skew**: Passenger vehicles and SUVs account for the large majority of recorded collisions, with commercial vehicles disproportionately represented in more severe crashes.
- **Spatial vs. Administrative Mismatch**: The point-level heatmap reveals hotspots (e.g., major arterial intersections) that don't align neatly with ZIP or borough-level choropleths — reinforcing why all three layers were kept separate.

---

## 🛠️ Technology Stack

- **Database**: PostgreSQL with PostGIS extension, run via Docker
- **Data Cleaning**: Python, Pandas
- **Database Connectivity**: SQLAlchemy, psycopg2
- **Data Visualization**: Plotly (analytics), Plotly/PostGIS-driven HTML exports (spatial)
- **Development Environment**: VS Code, Jupyter

---

## 📁 Project Structure

```
nyc_collision_analytics/
│
├── 📂 data/                    # Raw (untouched) and cleaned CSVs
├── 📂 sql/                     # Staging, normalization, and analytical view scripts
├── 📂 notebooks/                # Pandas cleaning + SQL/Plotly analysis notebooks
├── 📂 outputs/
│   ├── analytics/               # 11 PNG visualizations (Q01–Q11)
│   └── spatial/                 # 3 interactive HTML spatial outputs
├── 📄 docker-compose.yml        # PostgreSQL + PostGIS container setup
├── 📄 README.md                 # Project overview and instructions
└── 📄 requirements.txt          # Python dependencies
```

---

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/pradhumansoni/nyc-vehicle-collision-spatial-analytics.git
   cd nyc-vehicle-collision-spatial-analytics
   ```
2. **Start PostgreSQL + PostGIS**:
   ```bash
   docker-compose up -d
   ```
3. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
4. **Run the cleaning notebook**: Open `notebooks/01_cleaning.ipynb` to generate the cleaned CSV from the raw dataset.
5. **Load & normalize**: Run the scripts in `sql/` to load the cleaned CSV into staging, then build the 3NF `normalized` schema and `analytics.vw_collision_analysis` view.
6. **Run the analytics notebook**: Open `notebooks/02_sql_analytics.ipynb` to run the 11 SQL questions and generate the Plotly visualizations.
7. **Run the spatial notebook**: Open `notebooks/03_spatial_analysis.ipynb` to generate the three interactive HTML maps in `outputs/spatial/`.

---

## 🧭 Design Decisions & Scope Cuts

This project deliberately followed a **lean, evidence-first path** rather than the initially planned architecture:

- **No star schema / data warehouse**: A full dimensional model was considered but cut — 3NF on top of PostgreSQL was sufficient for the analytical questions being asked, and avoided unnecessary ETL complexity.
- **No large-scale warehouse ETL tooling**: Given the dataset size and scope, a Pandas → PostgreSQL pipeline was more appropriate than introducing Airflow/dbt-style orchestration.
- **Schema derived from data, not assumed**: The normalization strategy (repeating groups → `collision_vehicles` / `collision_factors`) came directly from profiling the data's actual dependencies, not a schema sketched before looking at the CSV.

The final pipeline:

```
NYC Collision CSV
      ↓
Pandas Cleaning
      ↓
Cleaned CSV
      ↓
PostgreSQL Staging
      ↓
Database Investigation
      ↓
3NF Normalization
      ↓
Analytical View
      ↓
11 SQL Analytical Questions
      ↓
Pandas + Plotly
      ↓
PostGIS / Geographic Data
      ↓
3 Spatial Visualizations
      ↓
Final Outputs + README
```

---

## 🤝 How to Contribute

Contributions are welcome. Fork the repository, create a feature branch, and open a pull request. Suggestions for additional SQL questions, alternative normalization approaches, or new spatial layers are especially welcome.

---

## 📞 Contact

- **Pradhuman Kumar Soni**
- M.Sc. Mathematics & Scientific Computing, NIT Warangal
- Feel free to connect via GitHub or LinkedIn.

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
