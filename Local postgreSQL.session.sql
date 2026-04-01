SELECT
    week_end,
    ROUND(percent_visits_smoothed_combined::NUMERIC, 2) AS ed_demand_pct,
    ROUND(pct_icu_beds_occupied::NUMERIC, 2)            AS icu_occupancy_pct,
    ROUND(pct_inpatient_beds_occupied::NUMERIC, 2)      AS inpatient_occupancy_pct,
    RANK() OVER (ORDER BY percent_visits_smoothed_combined DESC) AS demand_rank
FROM ed_demand_capacity_weekly_mi
ORDER BY demand_rank;