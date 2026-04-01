-- =============================================
-- PROJECT: MI ED Surge & Hospital Capacity Analytics
-- DATABASE: mi_ed_surge
-- TABLE: ed_demand_capacity_weekly_mi
-- DATE RANGE: 2023-01-07 to 2024-04-27
-- =============================================


-- =============================================
-- SETUP: Create and load table
-- =============================================

CREATE TABLE ed_demand_capacity_weekly_mi (
    week_end DATE,
    percent_visits_smoothed_combined NUMERIC,
    percent_visits_smoothed_influenza NUMERIC,
    percent_visits_smoothed_covid NUMERIC,
    geo TEXT,
    pct_reporting_days NUMERIC,
    avg_inpatient_beds TEXT,
    avg_icu_beds TEXT,
    avg_inpatient_beds_used TEXT,
    avg_icu_beds_used TEXT,
    pct_inpatient_beds_occupied NUMERIC,
    pct_icu_beds_occupied NUMERIC,
    avg_flu_hospitalizations TEXT,
    avg_covid_hospitalizations TEXT,
    avg_covid_icu_patients NUMERIC
);

-- Load data (run in psql terminal)
-- \copy ed_demand_capacity_weekly_mi FROM '/Users/amaanthasin/Downloads/MI_ED_Surge_Capacity_Analytics/data_curated/data_analysis/analysis_ed_demand_vs_capacity_weekly_mi.csv' WITH (FORMAT csv, HEADER true);

-- Clean comma-formatted numeric columns
ALTER TABLE ed_demand_capacity_weekly_mi
    ALTER COLUMN avg_inpatient_beds TYPE NUMERIC
        USING REPLACE(avg_inpatient_beds, ',', '')::NUMERIC,
    ALTER COLUMN avg_icu_beds TYPE NUMERIC
        USING REPLACE(avg_icu_beds, ',', '')::NUMERIC,
    ALTER COLUMN avg_inpatient_beds_used TYPE NUMERIC
        USING REPLACE(avg_inpatient_beds_used, ',', '')::NUMERIC,
    ALTER COLUMN avg_icu_beds_used TYPE NUMERIC
        USING REPLACE(avg_icu_beds_used, ',', '')::NUMERIC,
    ALTER COLUMN avg_flu_hospitalizations TYPE NUMERIC
        USING REPLACE(avg_flu_hospitalizations, ',', '')::NUMERIC,
    ALTER COLUMN avg_covid_hospitalizations TYPE NUMERIC
        USING REPLACE(avg_covid_hospitalizations, ',', '')::NUMERIC;


-- =============================================
-- QUERY 1: Rank weeks by ED demand
-- =============================================
SELECT
    week_end,
    ROUND(percent_visits_smoothed_combined::NUMERIC, 2) AS ed_demand_pct,
    ROUND(pct_icu_beds_occupied::NUMERIC, 2)            AS icu_occupancy_pct,
    ROUND(pct_inpatient_beds_occupied::NUMERIC, 2)      AS inpatient_occupancy_pct,
    RANK() OVER (ORDER BY percent_visits_smoothed_combined DESC) AS demand_rank
FROM ed_demand_capacity_weekly_mi
ORDER BY demand_rank;


-- =============================================
-- QUERY 2: Flag weeks by demand level
-- =============================================
SELECT
    week_end,
    ROUND(percent_visits_smoothed_combined::NUMERIC, 2) AS ed_demand_pct,
    ROUND(pct_icu_beds_occupied::NUMERIC, 2)            AS icu_occupancy_pct,
    CASE
        WHEN percent_visits_smoothed_combined >= 3.0 THEN 'High'
        WHEN percent_visits_smoothed_combined >= 1.5 THEN 'Moderate'
        ELSE 'Low'
    END AS demand_level
FROM ed_demand_capacity_weekly_mi
ORDER BY week_end;


-- =============================================
-- QUERY 3: Average ICU occupancy by demand level
-- =============================================
SELECT
    CASE
        WHEN percent_visits_smoothed_combined >= 3.0 THEN 'High'
        WHEN percent_visits_smoothed_combined >= 1.5 THEN 'Moderate'
        ELSE 'Low'
    END AS demand_level,
    COUNT(*)                                                   AS weeks,
    ROUND(AVG(percent_visits_smoothed_combined)::NUMERIC, 2)  AS avg_ed_demand,
    ROUND(AVG(pct_icu_beds_occupied)::NUMERIC, 2)             AS avg_icu_occupancy,
    ROUND(AVG(pct_inpatient_beds_occupied)::NUMERIC, 2)       AS avg_inpatient_occupancy
FROM ed_demand_capacity_weekly_mi
GROUP BY demand_level
ORDER BY avg_ed_demand DESC;


-- =============================================
-- QUERY 4: Lead-lag analysis (full dataset)
-- =============================================
SELECT
    curr.week_end,
    ROUND(curr.percent_visits_smoothed_combined::NUMERIC, 2)  AS ed_demand_pct,
    ROUND(curr.pct_icu_beds_occupied::NUMERIC, 2)             AS icu_same_week,
    ROUND(w1.pct_icu_beds_occupied::NUMERIC, 2)               AS icu_1_week_later,
    ROUND(w2.pct_icu_beds_occupied::NUMERIC, 2)               AS icu_2_weeks_later,
    ROUND(w3.pct_icu_beds_occupied::NUMERIC, 2)               AS icu_3_weeks_later
FROM ed_demand_capacity_weekly_mi curr
LEFT JOIN ed_demand_capacity_weekly_mi w1
    ON w1.week_end = curr.week_end + INTERVAL '7 days'
LEFT JOIN ed_demand_capacity_weekly_mi w2
    ON w2.week_end = curr.week_end + INTERVAL '14 days'
LEFT JOIN ed_demand_capacity_weekly_mi w3
    ON w3.week_end = curr.week_end + INTERVAL '21 days'
ORDER BY curr.week_end;


-- =============================================
-- QUERY 4b: Lead-lag during winter 2023/24 surge
-- =============================================
SELECT
    curr.week_end,
    ROUND(curr.percent_visits_smoothed_combined::NUMERIC, 2)  AS ed_demand_pct,
    ROUND(curr.pct_icu_beds_occupied::NUMERIC, 2)             AS icu_same_week,
    ROUND(w1.pct_icu_beds_occupied::NUMERIC, 2)               AS icu_1_week_later,
    ROUND(w2.pct_icu_beds_occupied::NUMERIC, 2)               AS icu_2_weeks_later,
    ROUND(w3.pct_icu_beds_occupied::NUMERIC, 2)               AS icu_3_weeks_later
FROM ed_demand_capacity_weekly_mi curr
LEFT JOIN ed_demand_capacity_weekly_mi w1
    ON w1.week_end = curr.week_end + INTERVAL '7 days'
LEFT JOIN ed_demand_capacity_weekly_mi w2
    ON w2.week_end = curr.week_end + INTERVAL '14 days'
LEFT JOIN ed_demand_capacity_weekly_mi w3
    ON w3.week_end = curr.week_end + INTERVAL '21 days'
WHERE curr.week_end BETWEEN '2023-11-01' AND '2024-03-31'
ORDER BY curr.week_end;


-- =============================================
-- QUERY 5: Average ICU change after high demand
-- =============================================
SELECT
    ROUND(AVG(w2.pct_icu_beds_occupied - curr.pct_icu_beds_occupied)::NUMERIC, 2) AS avg_icu_change_2wks_after_high_demand
FROM ed_demand_capacity_weekly_mi curr
LEFT JOIN ed_demand_capacity_weekly_mi w2
    ON w2.week_end = curr.week_end + INTERVAL '14 days'
WHERE curr.percent_visits_smoothed_combined >= 3.0;


-- =============================================
-- QUERY 6: Lead-lag on rising demand only
-- KEY FINDING: +0.85% ICU occupancy within 2 weeks
-- =============================================
SELECT
    ROUND(AVG(w2.pct_icu_beds_occupied - curr.pct_icu_beds_occupied)::NUMERIC, 2) AS avg_icu_change_2wks_later,
    COUNT(*) AS weeks_counted
FROM ed_demand_capacity_weekly_mi curr
LEFT JOIN ed_demand_capacity_weekly_mi w2
    ON w2.week_end = curr.week_end + INTERVAL '14 days'
LEFT JOIN ed_demand_capacity_weekly_mi prev
    ON prev.week_end = curr.week_end - INTERVAL '7 days'
WHERE curr.percent_visits_smoothed_combined >= 3.0
AND curr.percent_visits_smoothed_combined > prev.percent_visits_smoothed_combined;


-- =============================================
-- VIEW 1: Weekly demand and capacity summary
-- For Power BI: main trend visualization
-- =============================================
CREATE VIEW vw_weekly_demand_capacity AS
SELECT
    week_end,
    ROUND(percent_visits_smoothed_combined::NUMERIC, 2)  AS ed_demand_pct,
    ROUND(percent_visits_smoothed_influenza::NUMERIC, 2) AS ed_demand_flu,
    ROUND(percent_visits_smoothed_covid::NUMERIC, 2)     AS ed_demand_covid,
    ROUND(pct_icu_beds_occupied::NUMERIC, 2)             AS icu_occupancy_pct,
    ROUND(pct_inpatient_beds_occupied::NUMERIC, 2)       AS inpatient_occupancy_pct,
    ROUND(avg_flu_hospitalizations::NUMERIC, 0)          AS flu_hospitalizations,
    ROUND(avg_covid_hospitalizations::NUMERIC, 0)        AS covid_hospitalizations,
    CASE
        WHEN percent_visits_smoothed_combined >= 3.0 THEN 'High'
        WHEN percent_visits_smoothed_combined >= 1.5 THEN 'Moderate'
        ELSE 'Low'
    END AS demand_level
FROM ed_demand_capacity_weekly_mi;


-- =============================================
-- VIEW 2: Lead-lag early warning system
-- For Power BI: early warning dashboard
-- KEY INSIGHT: 2-week lead time before ICU peaks
-- =============================================
CREATE VIEW vw_lead_lag_early_warning AS
SELECT
    curr.week_end,
    ROUND(curr.percent_visits_smoothed_combined::NUMERIC, 2) AS ed_demand_pct,
    ROUND(curr.pct_icu_beds_occupied::NUMERIC, 2)            AS icu_same_week,
    ROUND(w1.pct_icu_beds_occupied::NUMERIC, 2)              AS icu_1_week_later,
    ROUND(w2.pct_icu_beds_occupied::NUMERIC, 2)              AS icu_2_weeks_later,
    ROUND(w3.pct_icu_beds_occupied::NUMERIC, 2)              AS icu_3_weeks_later,
    CASE
        WHEN curr.percent_visits_smoothed_combined >= 3.0 THEN 'High'
        WHEN curr.percent_visits_smoothed_combined >= 1.5 THEN 'Moderate'
        ELSE 'Low'
    END AS demand_level,
    CASE
        WHEN curr.percent_visits_smoothed_combined >= 3.0
        AND curr.percent_visits_smoothed_combined > prev.percent_visits_smoothed_combined
        THEN 'EARLY WARNING'
        ELSE 'Normal'
    END AS warning_status
FROM ed_demand_capacity_weekly_mi curr
LEFT JOIN ed_demand_capacity_weekly_mi prev
    ON prev.week_end = curr.week_end - INTERVAL '7 days'
LEFT JOIN ed_demand_capacity_weekly_mi w1
    ON w1.week_end = curr.week_end + INTERVAL '7 days'
LEFT JOIN ed_demand_capacity_weekly_mi w2
    ON w2.week_end = curr.week_end + INTERVAL '14 days'
LEFT JOIN ed_demand_capacity_weekly_mi w3
    ON w3.week_end = curr.week_end + INTERVAL '21 days';