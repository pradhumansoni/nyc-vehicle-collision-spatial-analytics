-- ============================================================
-- NYC Vehicle Collision Analytics
-- 03_data_profiling.sql
-- ============================================================

-- ============================================================
-- 1. TABLE PROFILE
-- ============================================================

SELECT count(*)
from staging.raw_collisions;

SELECT count(*) as Total_Columns
FROM information_schema.columns
WHERE table_schema = 'staging'
AND table_name = 'raw_collisions';

-- =======================================================================================
SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'raw_collisions'
ORDER BY ordinal_position;

-- =======================================================================================
SELECT
    column_name,
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(value) AS null_count,
    ROUND(
        100.0 * (COUNT(*) - COUNT(value)) / COUNT(*),
        2
    ) AS null_percentage
FROM staging.raw_collisions r
CROSS JOIN LATERAL (
    VALUES
        ('crash_date', r.crash_date::TEXT),
        ('crash_time', r.crash_time::TEXT),
        ('borough', r.borough::TEXT),
        ('zip_code', r.zip_code::TEXT),
        ('latitude', r.latitude::TEXT),
        ('longitude', r.longitude::TEXT),
        ('location', r.location::TEXT),
        ('on_street_name', r.on_street_name::TEXT),
        ('cross_street_name', r.cross_street_name::TEXT),
        ('off_street_name', r.off_street_name::TEXT),
        ('number_of_persons_injured', r.number_of_persons_injured::TEXT),
        ('number_of_persons_killed', r.number_of_persons_killed::TEXT),
        ('number_of_pedestrians_injured', r.number_of_pedestrians_injured::TEXT),
        ('number_of_pedestrians_killed', r.number_of_pedestrians_killed::TEXT),
        ('number_of_cyclist_injured', r.number_of_cyclist_injured::TEXT),
        ('number_of_cyclist_killed', r.number_of_cyclist_killed::TEXT),
        ('number_of_motorist_injured', r.number_of_motorist_injured::TEXT),
        ('number_of_motorist_killed', r.number_of_motorist_killed::TEXT),
        ('contributing_factor_vehicle_1', r.contributing_factor_vehicle_1::TEXT),
        ('contributing_factor_vehicle_2', r.contributing_factor_vehicle_2::TEXT),
        ('contributing_factor_vehicle_3', r.contributing_factor_vehicle_3::TEXT),
        ('contributing_factor_vehicle_4', r.contributing_factor_vehicle_4::TEXT),
        ('contributing_factor_vehicle_5', r.contributing_factor_vehicle_5::TEXT),
        ('collision_id', r.collision_id::TEXT),
        ('vehicle_type_code_1', r.vehicle_type_code_1::TEXT),
        ('vehicle_type_code_2', r.vehicle_type_code_2::TEXT),
        ('vehicle_type_code_3', r.vehicle_type_code_3::TEXT),
        ('vehicle_type_code_4', r.vehicle_type_code_4::TEXT),
        ('vehicle_type_code_5', r.vehicle_type_code_5::TEXT)
) AS v(column_name, value)
GROUP BY column_name
ORDER BY null_count DESC;

-- ============================================================================================

-- ============================================================
-- 3. DUPLICATE ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT collision_id) AS distinct_collision_ids,
    COUNT(*) - COUNT(DISTINCT collision_id) AS duplicate_excess
FROM staging.raw_collisions; -- Zero duplicate records

SELECT
    collision_id,
    COUNT(*) AS record_count
FROM staging.raw_collisions
GROUP BY collision_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC, collision_id; -- Empty table (shows No Duplicate records)

-- ============================================================
-- 3. DUPLICATE ANALYSIS
-- ============================================================
--
-- Result:
-- Total rows            : 2,269,187
-- Distinct collision_id : 2,269,187
-- Duplicate excess      : 0
--
-- Conclusion:
-- COLLISION_ID is unique in the staging dataset.
-- No duplicate removal is required based on COLLISION_ID.


-- ============================================================
-- 4. CARDINALITY ANALYSIS
-- ============================================================

SELECT
    COUNT(DISTINCT vehicle_type_code_1) AS vehicle_type_1_cardinality,
    COUNT(DISTINCT vehicle_type_code_2) AS vehicle_type_2_cardinality,
    COUNT(DISTINCT vehicle_type_code_3) AS vehicle_type_3_cardinality,
    COUNT(DISTINCT vehicle_type_code_4) AS vehicle_type_4_cardinality,
    COUNT(DISTINCT vehicle_type_code_5) AS vehicle_type_5_cardinality
FROM staging.raw_collisions;

SELECT
    vehicle_type_code_1,
    COUNT(*) AS occurrence_count
FROM staging.raw_collisions
GROUP BY vehicle_type_code_1
ORDER BY occurrence_count DESC
LIMIT 20;

-- ============================================================
-- 4. VEHICLE TYPE CARDINALITY
-- ============================================================
--
-- Distinct non-NULL values:
-- vehicle_type_code_1 : 1,905
-- vehicle_type_code_2 : 2,132
-- vehicle_type_code_3 : 317
-- vehicle_type_code_4 : 125
-- vehicle_type_code_5 : 81
--
-- Initial observations:
-- 1. Vehicle type columns form a repeating group.
-- 2. Vehicle type values show inconsistent capitalization.
-- 3. Some values may represent the same conceptual category
--    using different textual representations.
--
-- Cleaning decisions will be made after further profiling.


-- ============================================================
-- 5. Quantify the Inconsistency Problem 
-- ============================================================

SELECT
    LOWER(TRIM(vehicle_type_code_1)) AS normalized_text,
    COUNT(DISTINCT vehicle_type_code_1) AS source_variations,
    COUNT(*) AS total_occurrences
FROM staging.raw_collisions
WHERE vehicle_type_code_1 IS NOT NULL
GROUP BY LOWER(TRIM(vehicle_type_code_1))
HAVING COUNT(DISTINCT vehicle_type_code_1) > 1
ORDER BY source_variations DESC, total_occurrences DESC;