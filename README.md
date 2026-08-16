# NYC Vehicle Collision Analytics

End-to-end data engineering and analytics project using the NYC Motor Vehicle Collisions dataset.

## Project Overview

The project transforms raw collision data into a structured analytical system through:

```text
Raw Data
   ↓
Pandas Data Cleaning
   ↓
PostgreSQL Staging
   ↓
3NF Relational Normalization
   ↓
Analytical SQL
   ↓
PostGIS Spatial Analysis
   ↓
Plotly + Folium Visualization
```
Tech Stack
Python: Pandas, GeoPandas, Plotly, Folium
Database: PostgreSQL, PostGIS
Connectivity: SQLAlchemy, psycopg2
Infrastructure: Docker
Environment: Jupyter Notebook / VS Code
Key Components
Data Engineering
Data cleaning and validation using Pandas
PostgreSQL staging layer
Data quality and relationship investigation
3NF relational database design
Normalization of repeating vehicle and contributing-factor fields
SQL Analytics

11 analytical questions covering:

Yearly and monthly collision trends
Time-of-day and hourly patterns
Weekday vs. weekend collisions
Borough-level collision and injury analysis
Collision severity
Contributing factors
Vehicle types
Vehicle types by borough
Spatial Analysis

Three standalone interactive maps:

Collision Location Heatmap
ZIP Code Choropleth
Borough Choropleth
Repository Structure
nyc-vehicle-collision-analytics/
│
├── data/
├── notebooks/
├── sql/
├── outputs/
│   ├── analytics/
│   └── spatial/
├── docker-compose.yml
├── requirements.txt
└── README.md
Key Outcome

The project demonstrates a complete workflow from raw public data → cleaned data → normalized relational database → SQL analytics → spatial analysis and visualization, while keeping the architecture practical and focused.
