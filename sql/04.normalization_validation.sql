-- ===========================================================
-- Validate the normalization
-- ===========================================================

--collision count

SELECT COUNT(*) AS collision_count
FROM normalized.collisions;

-- vehicle type count

SELECT COUNT(*) AS vehicle_type_count
FROM normalized.vehicle_types;

-- collision vehicle count

SELECT COUNT(*) AS collision_vehicle_count
FROM normalized.collision_vehicles;

-- factor count

SELECT COUNT(*) AS factor_count
FROM normalized.contributing_factors;

-- collision factor count

SELECT COUNT(*) AS collision_factor_count
FROM normalized.collision_factors;

-- ======================================================
-- Referential Integrity
-- ======================================================

SELECT COUNT(*) AS orphan_collision_vehicles
FROM normalized.collision_vehicles cv
LEFT JOIN normalized.collisions c
    ON cv.collision_id = c.collision_id
WHERE c.collision_id IS NULL;


SELECT COUNT(*) AS orphan_vehicle_types
FROM normalized.collision_vehicles cv
LEFT JOIN normalized.vehicle_types vt
    ON cv.vehicle_type_key = vt.vehicle_type_key
WHERE vt.vehicle_type_key IS NULL;

SELECT COUNT(*) AS orphan_collision_factors
FROM normalized.collision_factors cf
LEFT JOIN normalized.collisions c
    ON cf.collision_id = c.collision_id
WHERE c.collision_id IS NULL;

SELECT COUNT(*) AS orphan_factors
FROM normalized.collision_factors cf
LEFT JOIN normalized.contributing_factors f
    ON cf.factor_key = f.factor_key
WHERE f.factor_key IS NULL;

-- =================================================
-- Information-Preservation / Reconstruction Test
-- =================================================


-- 1. Vehicle reconstruction test

SELECT
    c.collision_id,

    c.vehicle_type_code_1,
    c.vehicle_type_code_2,
    c.vehicle_type_code_3,
    c.vehicle_type_code_4,
    c.vehicle_type_code_5,

    STRING_AGG(
        vt.vehicle_type_code,
        ' | '
        ORDER BY cv.vehicle_sequence
    ) AS normalized_vehicle_types

FROM staging.cleaned_collisions c

LEFT JOIN normalized.collision_vehicles cv
    ON c.collision_id = cv.collision_id

LEFT JOIN normalized.vehicle_types vt
    ON cv.vehicle_type_key = vt.vehicle_type_key

GROUP BY
    c.collision_id,
    c.vehicle_type_code_1,
    c.vehicle_type_code_2,
    c.vehicle_type_code_3,
    c.vehicle_type_code_4,
    c.vehicle_type_code_5

ORDER BY c.collision_id
LIMIT 20;

-- 2. Factor reconstruction

SELECT
    c.collision_id,

    c.contributing_factor_vehicle_1,
    c.contributing_factor_vehicle_2,
    c.contributing_factor_vehicle_3,
    c.contributing_factor_vehicle_4,
    c.contributing_factor_vehicle_5,

    STRING_AGG(
        f.factor_description,
        ' | '
        ORDER BY cf.factor_sequence
    ) AS normalized_factors

FROM staging.cleaned_collisions c

LEFT JOIN normalized.collision_factors cf
    ON c.collision_id = cf.collision_id

LEFT JOIN normalized.contributing_factors f
    ON cf.factor_key = f.factor_key

GROUP BY
    c.collision_id,
    c.contributing_factor_vehicle_1,
    c.contributing_factor_vehicle_2,
    c.contributing_factor_vehicle_3,
    c.contributing_factor_vehicle_4,
    c.contributing_factor_vehicle_5

ORDER BY c.collision_id
LIMIT 20;

-- 3. Automated count validation

SELECT
    (
        COUNT(*) FILTER (WHERE vehicle_type_code_1 IS NOT NULL)
      + COUNT(*) FILTER (WHERE vehicle_type_code_2 IS NOT NULL)
      + COUNT(*) FILTER (WHERE vehicle_type_code_3 IS NOT NULL)
      + COUNT(*) FILTER (WHERE vehicle_type_code_4 IS NOT NULL)
      + COUNT(*) FILTER (WHERE vehicle_type_code_5 IS NOT NULL)
    ) AS source_vehicle_occurrences,

    (
        SELECT COUNT(*)
        FROM normalized.collision_vehicles
    ) AS normalized_vehicle_occurrences
FROM staging.cleaned_collisions;

SELECT
    (
        COUNT(*) FILTER (WHERE contributing_factor_vehicle_1 IS NOT NULL)
      + COUNT(*) FILTER (WHERE contributing_factor_vehicle_2 IS NOT NULL)
      + COUNT(*) FILTER (WHERE contributing_factor_vehicle_3 IS NOT NULL)
      + COUNT(*) FILTER (WHERE contributing_factor_vehicle_4 IS NOT NULL)
      + COUNT(*) FILTER (WHERE contributing_factor_vehicle_5 IS NOT NULL)
    ) AS source_factor_occurrences,

    (
        SELECT COUNT(*)
        FROM normalized.collision_factors
    ) AS normalized_factor_occurrences
FROM staging.cleaned_collisions;