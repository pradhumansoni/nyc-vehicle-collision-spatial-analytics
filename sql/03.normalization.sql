-- ============================================================
-- 03_normalization.sql
-- NYC Vehicle Collision Analytics
-- Normalized / 3NF Layer
-- ============================================================

-- ------------------------------------------------------------
-- 1. COLLISIONS
-- ------------------------------------------------------------

DROP TABLE IF EXISTS normalized.collision_factors CASCADE;
DROP TABLE IF EXISTS normalized.collision_vehicles CASCADE;
DROP TABLE IF EXISTS normalized.contributing_factors CASCADE;
DROP TABLE IF EXISTS normalized.vehicle_types CASCADE;
DROP TABLE IF EXISTS normalized.collisions CASCADE;


CREATE TABLE normalized.collisions (
    collision_id BIGINT PRIMARY KEY,

    crash_date DATE NOT NULL,
    crash_time TIME NOT NULL,

    -- Reported geographic attributes
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    borough TEXT,
    zip_code TEXT,
    on_street_name TEXT,
    cross_street_name TEXT,
    off_street_name TEXT,

    -- Collision severity
    number_of_persons_injured INTEGER,
    number_of_persons_killed INTEGER,

    -- Pedestrians
    number_of_pedestrians_injured INTEGER NOT NULL,
    number_of_pedestrians_killed INTEGER NOT NULL,

    -- Cyclists
    number_of_cyclist_injured INTEGER NOT NULL,
    number_of_cyclist_killed INTEGER NOT NULL,

    -- Motorists
    number_of_motorist_injured INTEGER NOT NULL,
    number_of_motorist_killed INTEGER NOT NULL
);

-- We are keeping the attributes that describe the collision itself.


-- ------------------------------------------------------------
-- 2. VEHICLE TYPES
-- ------------------------------------------------------------

CREATE TABLE normalized.vehicle_types (
    vehicle_type_key BIGSERIAL PRIMARY KEY,

    vehicle_type_code TEXT NOT NULL,

    CONSTRAINT uq_vehicle_type_code
        UNIQUE (vehicle_type_code)
);


-- ------------------------------------------------------------
-- 3. COLLISION VEHICLES
-- ------------------------------------------------------------

CREATE TABLE normalized.collision_vehicles (
    collision_vehicle_key BIGSERIAL PRIMARY KEY,

    collision_id BIGINT NOT NULL,

    vehicle_type_key BIGINT NOT NULL,

    vehicle_sequence SMALLINT NOT NULL,

    CONSTRAINT fk_collision_vehicle_collision
        FOREIGN KEY (collision_id)
        REFERENCES normalized.collisions(collision_id),

    CONSTRAINT fk_collision_vehicle_type
        FOREIGN KEY (vehicle_type_key)
        REFERENCES normalized.vehicle_types(vehicle_type_key),

    CONSTRAINT chk_vehicle_sequence
        CHECK (vehicle_sequence BETWEEN 1 AND 5),

    CONSTRAINT uq_collision_vehicle_sequence
        UNIQUE (collision_id, vehicle_sequence)
);


-- ------------------------------------------------------------
-- 4. CONTRIBUTING FACTORS
-- ------------------------------------------------------------

CREATE TABLE normalized.contributing_factors (
    factor_key BIGSERIAL PRIMARY KEY,

    factor_description TEXT NOT NULL,

    CONSTRAINT uq_factor_description
        UNIQUE (factor_description)
);


-- ------------------------------------------------------------
-- 5. COLLISION FACTORS
-- ------------------------------------------------------------

CREATE TABLE normalized.collision_factors (
    collision_factor_key BIGSERIAL PRIMARY KEY,

    collision_id BIGINT NOT NULL,

    factor_key BIGINT NOT NULL,

    factor_sequence SMALLINT NOT NULL,

    CONSTRAINT fk_collision_factor_collision
        FOREIGN KEY (collision_id)
        REFERENCES normalized.collisions(collision_id),

    CONSTRAINT fk_collision_factor_factor
        FOREIGN KEY (factor_key)
        REFERENCES normalized.contributing_factors(factor_key),

    CONSTRAINT chk_factor_sequence
        CHECK (factor_sequence BETWEEN 1 AND 5),

    CONSTRAINT uq_collision_factor_sequence
        UNIQUE (collision_id, factor_sequence)
);


-- ============================================================
-- POPULATE NORMALIZED.COLLISIONS
-- ============================================================

INSERT INTO normalized.collisions (
    collision_id,
    crash_date,
    crash_time,
    latitude,
    longitude,
    borough,
    zip_code,
    on_street_name,
    cross_street_name,
    off_street_name,
    number_of_persons_injured,
    number_of_persons_killed,
    number_of_pedestrians_injured,
    number_of_pedestrians_killed,
    number_of_cyclist_injured,
    number_of_cyclist_killed,
    number_of_motorist_injured,
    number_of_motorist_killed
)
SELECT
    collision_id,
    crash_date,
    crash_time,
    latitude,
    longitude,
    borough,
    zip_code,
    on_street_name,
    cross_street_name,
    off_street_name,
    number_of_persons_injured,
    number_of_persons_killed,
    number_of_pedestrians_injured,
    number_of_pedestrians_killed,
    number_of_cyclist_injured,
    number_of_cyclist_killed,
    number_of_motorist_injured,
    number_of_motorist_killed
FROM staging.cleaned_collisions;

-- ============================================================
-- POPULATE NORMALIZED.VEHICLE_TYPES
-- ============================================================

INSERT INTO normalized.vehicle_types (
    vehicle_type_code
)
SELECT DISTINCT vehicle_type
FROM (
    SELECT vehicle_type_code_1 AS vehicle_type
    FROM staging.cleaned_collisions

    UNION ALL

    SELECT vehicle_type_code_2
    FROM staging.cleaned_collisions

    UNION ALL

    SELECT vehicle_type_code_3
    FROM staging.cleaned_collisions

    UNION ALL

    SELECT vehicle_type_code_4
    FROM staging.cleaned_collisions

    UNION ALL

    SELECT vehicle_type_code_5
    FROM staging.cleaned_collisions
) AS vehicle_values
WHERE vehicle_type IS NOT NULL
ORDER BY vehicle_type;

-- ============================================================
-- POPULATE NORMALIZED.COLLISION_VEHICLES
-- ============================================================


INSERT INTO normalized.collision_vehicles (
    collision_id,
    vehicle_type_key,
    vehicle_sequence
)
SELECT
    c.collision_id,
    vt.vehicle_type_key,
    v.vehicle_sequence
FROM staging.cleaned_collisions c
CROSS JOIN LATERAL (
    VALUES
        (1, c.vehicle_type_code_1),
        (2, c.vehicle_type_code_2),
        (3, c.vehicle_type_code_3),
        (4, c.vehicle_type_code_4),
        (5, c.vehicle_type_code_5)
) AS v(vehicle_sequence, vehicle_type)
JOIN normalized.vehicle_types vt
    ON vt.vehicle_type_code = v.vehicle_type
WHERE v.vehicle_type IS NOT NULL;

-- ============================================================
-- POPULATE NORMALIZED.CONTRIBUTING_FACTORS
-- ============================================================

INSERT INTO normalized.contributing_factors (
    factor_description
)
SELECT DISTINCT contributing_factor
FROM (
    SELECT contributing_factor_vehicle_1 AS contributing_factor
    FROM staging.cleaned_collisions

    UNION ALL

    SELECT contributing_factor_vehicle_2
    FROM staging.cleaned_collisions

    UNION ALL

    SELECT contributing_factor_vehicle_3
    FROM staging.cleaned_collisions

    UNION ALL

    SELECT contributing_factor_vehicle_4
    FROM staging.cleaned_collisions

    UNION ALL

    SELECT contributing_factor_vehicle_5
    FROM staging.cleaned_collisions
) AS factor_values
WHERE contributing_factor IS NOT NULL
ORDER BY contributing_factor;

-- ============================================================
-- POPULATE NORMALIZED.COLLISION_FACTORS
-- ============================================================

INSERT INTO normalized.collision_factors (
    collision_id,
    factor_key,
    factor_sequence
)
SELECT
    c.collision_id,
    cf.factor_key,
    f.factor_sequence
FROM staging.cleaned_collisions c
CROSS JOIN LATERAL (
    VALUES
        (1, c.contributing_factor_vehicle_1),
        (2, c.contributing_factor_vehicle_2),
        (3, c.contributing_factor_vehicle_3),
        (4, c.contributing_factor_vehicle_4),
        (5, c.contributing_factor_vehicle_5)
) AS f(factor_sequence, factor_description)
JOIN normalized.contributing_factors cf
    ON cf.factor_description = f.factor_description
WHERE f.factor_description IS NOT NULL;

