# Michigan ED Surge & Hospital Capacity Analytics

A portfolio-level healthcare operations analytics project examining the relationship between emergency department demand and hospital capacity utilization in Michigan — and whether ED signals can serve as an early warning system for ICU pressure.

---

## Business Question

> Can hospitals anticipate periods of high ICU capacity utilization using early emergency department demand signals?

More specifically:
- Does ED respiratory demand increase *before* ICU occupancy rises?
- Can this relationship be used to support early staffing and resource planning decisions?

---

## Key Finding

**When Michigan ED combined respiratory demand exceeded 3% and was still rising, ICU occupancy increased by an average of 0.85 percentage points within 2 weeks — across 7 of 10 identified early warning weeks.**

This represents a actionable 2-week early warning window for hospital operations teams to prepare staffing and resource allocation ahead of capacity pressure.

---

## Data Sources

Both datasets are real, publicly available from the CDC.

| Dataset | Source | Coverage |
|---|---|---|
| ED Visit Trajectories | CDC NSSP (National Syndromic Surveillance Program) | Michigan only, weekly, Jan 2023 – Apr 2024 |
| Hospital Capacity & Utilization | CDC NHSN (National Healthcare Safety Network) | Michigan only, weekly, reporting quality ≥ 90% |

---

## Tools & Technologies

- **Python** — data cleaning, integration, and visualization (pandas, plotly)
- **PostgreSQL** — structured analysis via SQL queries and reusable views
- **Tableau** — interactive dashboard (ED demand vs ICU occupancy, demand level bar chart)
- **Jupyter Notebooks** — reproducible analysis and visualization pipeline

---

## Project Structure
```
MI_ED_Surge_Capacity_Analytics/
│
├── data_curated/
│   ├── nssp_ed_demand_weekly_michigan_curated.csv      # Cleaned ED demand data
│   ├── nhsn_capacity_weekly_mi_curated.csv             # Cleaned hospital capacity data
│   └── data_analysis/
│       ├── analysis_ed_demand_vs_capacity_weekly_mi.csv  # Joined dataset (69 weeks)
│       ├── vw_weekly_demand_capacity.csv               # SQL view export for Tableau
│       ├── vw_lead_lag_early_warning.csv               # Early warning view export
│       └── early_warning_chart.html                    # Interactive Plotly chart
│
├── curate_nhsn_ed_demand.ipynb                         # NHSN data cleaning notebook
├── curate_nssp_ed_demand.ipynb                         # NSSP data cleaning notebook
├── joined_tables_workbook.ipynb                        # Data integration notebook
├── visualization_early_warning.ipynb                   # Plotly visualization notebook
└── sql_analysis_queries.sql                            # All SQL queries and views
```

---

## SQL Analysis

All analysis was conducted in PostgreSQL against a local database (`mi_ed_surge`), using the table `ed_demand_capacity_weekly_mi`.

Key queries and views built:

| Query | Purpose |
|---|---|
| Query 1 | Rank all 69 weeks by ED demand |
| Query 2 | Flag weeks as High / Moderate / Low demand |
| Query 3 | Average ICU occupancy by demand level |
| Query 4 | Lead-lag analysis — ICU occupancy 1, 2, 3 weeks after ED demand |
| Query 5 | Average ICU change after high demand weeks |
| Query 6 | Average ICU change during *rising* high demand weeks only |
| View 1 | `vw_weekly_demand_capacity` — weekly summary for Tableau |
| View 2 | `vw_lead_lag_early_warning` — early warning system view |

---

## Visualizations

### 1. ED Demand vs ICU Occupancy — Annotated Line Chart (Plotly)
**File:** `early_warning_chart.html`

Interactive dual-axis line chart showing ED combined respiratory demand and ICU occupancy over 69 weeks. Key features:
- Green shaded zone below the 3% early warning threshold
- Orange dots marking weeks where ED demand crossed the threshold
- Two highlighted warning periods (Wave 1: Nov–Dec 2023, Wave 2: Feb 2024)
- Hover tooltips showing exact weekly values for both metrics

### 2. ED Demand vs ICU Occupancy — Trend Overview (Tableau)
Dual-axis line chart showing the full 69-week timeline. Clearly shows two respiratory waves and the corresponding ICU response with a 2-week lag.

### 3. Average ICU Occupancy by Demand Level (Tableau)
Horizontal bar chart showing average ICU occupancy across three demand levels:
- High demand weeks: **76.2%** avg ICU occupancy
- Moderate demand weeks: **73.4%** avg ICU occupancy
- Low demand weeks: **71.8%** avg ICU occupancy

A 4.4 percentage point difference between Low and High demand — equivalent to approximately 120 additional ICU beds occupied.

---

## Key Insights

1. **Clear demand-capacity relationship** — ICU occupancy consistently stepped up with ED demand level across all 69 weeks.

2. **2-week early warning window** — ED demand reliably signaled ICU pressure 2 weeks in advance during both surge periods.

3. **Michigan ICU never hit crisis level** — occupancy stayed in the 70–79% range throughout, never crossing 80%. This reflects a system under chronic elevated pressure rather than acute crisis — a more realistic and operationally relevant finding.

4. **Two distinct surge patterns** — Winter 2022/23 was COVID-driven; Winter 2023/24 was influenza-driven. Both triggered the same early warning signal despite different pathogen profiles.

5. **Actionable threshold identified** — When ED combined respiratory demand exceeds 3% and is rising week-over-week, hospitals should initiate staffing and resource review protocols.

---

## How to Run

### Prerequisites
- Python 3.x with pandas, plotly installed
- PostgreSQL running locally
- Jupyter Notebook

### Steps
1. Clone or download the repository
2. Run the cleaning notebooks in order: `curate_nssp_ed_demand.ipynb` → `curate_nhsn_ed_demand.ipynb` → `joined_tables_workbook.ipynb`
3. Create the PostgreSQL database and load data using `sql_analysis_queries.sql`
4. Run `visualization_early_warning.ipynb` to generate the interactive chart
5. Open `early_warning_chart.html` in any browser to view the interactive visualization
6. Open the Tableau workbook to explore the dashboard

---

## Author

**Amaan Thasin**
Michigan State University
Healthcare Analytics Portfolio Project · 2026
