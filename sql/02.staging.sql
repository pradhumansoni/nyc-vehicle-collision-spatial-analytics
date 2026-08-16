-- ============================================================
-- NYC Vehicle Collision Analytics
-- 02_staging.sql
-- ============================================================

DROP TABLE IF EXISTS staging.raw_collisions;

CREATE TABLE staging.raw_collisions (
    crash_date                      TEXT,
    crash_time                      TEXT,
    borough                         TEXT,
    zip_code                        TEXT,
    latitude                        NUMERIC,
    longitude                       NUMERIC,
    location                        TEXT,
    on_street_name                  TEXT,
    cross_street_name               TEXT,
    off_street_name                 TEXT,
    number_of_persons_injured       NUMERIC,
    number_of_persons_killed        NUMERIC,
    number_of_pedestrians_injured   INTEGER,
    number_of_pedestrians_killed   INTEGER,
    number_of_cyclist_injured       INTEGER,
    number_of_cyclist_killed        INTEGER,
    number_of_motorist_injured      INTEGER,
    number_of_motorist_killed       INTEGER,

    contributing_factor_vehicle_1   TEXT,
    contributing_factor_vehicle_2   TEXT,
    contributing_factor_vehicle_3   TEXT,
    contributing_factor_vehicle_4   TEXT,
    contributing_factor_vehicle_5   TEXT,

    collision_id                    BIGINT,

    vehicle_type_code_1             TEXT,
    vehicle_type_code_2             TEXT,
    vehicle_type_code_3             TEXT,
    vehicle_type_code_4             TEXT,
    vehicle_type_code_5             TEXT
);
#----------------------------------------
# Test the Table Creation
#----------------------------------------
select count(*)
from staging.raw_collisions --0

SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'raw_collisions'
ORDER BY ordinal_position;