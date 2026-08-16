CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE VIEW analytics.vw_collision_analysis AS

SELECT
    c.collision_id,

    -- Original temporal fields
    c.crash_date,
    c.crash_time,

    -- Temporal attributes
    EXTRACT(YEAR FROM c.crash_date)::INT AS crash_year,

    EXTRACT(MONTH FROM c.crash_date)::INT AS crash_month,

    TRIM(TO_CHAR(c.crash_date, 'Month')) AS crash_month_name,

    EXTRACT(DAY FROM c.crash_date)::INT AS crash_day,

    EXTRACT(ISODOW FROM c.crash_date)::INT AS crash_day_of_week,

    TRIM(TO_CHAR(c.crash_date, 'Day')) AS crash_day_name,

    EXTRACT(WEEK FROM c.crash_date)::INT AS crash_week,

    EXTRACT(HOUR FROM c.crash_time)::INT AS crash_hour,

    CASE
        WHEN EXTRACT(ISODOW FROM c.crash_date) IN (6, 7)
        THEN TRUE
        ELSE FALSE
    END AS is_weekend,

    CASE
        WHEN EXTRACT(HOUR FROM c.crash_time) BETWEEN 0 AND 5
            THEN 'NIGHT'

        WHEN EXTRACT(HOUR FROM c.crash_time) BETWEEN 6 AND 11
            THEN 'MORNING'

        WHEN EXTRACT(HOUR FROM c.crash_time) BETWEEN 12 AND 17
            THEN 'AFTERNOON'

        ELSE 'EVENING'
    END AS time_of_day,

    -- Location
    c.borough,
    c.zip_code,
    c.latitude,
    c.longitude,
    c.on_street_name,
    c.cross_street_name,
    c.off_street_name,

    -- Collision severity measures
    c.number_of_persons_injured,
    c.number_of_persons_killed,

    c.number_of_pedestrians_injured,
    c.number_of_pedestrians_killed,

    c.number_of_cyclist_injured,
    c.number_of_cyclist_killed,

    c.number_of_motorist_injured,
    c.number_of_motorist_killed

FROM normalized.collisions AS c;


-- Verify the view created:
SELECT *
FROM analytics.vw_collision_analysis
LIMIT 10;

SELECT
    crash_date,
    crash_time,
    crash_year,
    crash_month,
    crash_month_name,
    crash_day_name,
    crash_hour,
    is_weekend,
    time_of_day
FROM analytics.vw_collision_analysis
LIMIT 20;