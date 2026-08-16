-- ============================================================
-- NYC Vehicle Collision Analytics
-- 01_schemas.sql
-- ============================================================

CREATE SCHEMA IF NOT EXISTS staging;

CREATE SCHEMA IF NOT EXISTS normalized;

CREATE SCHEMA IF NOT EXISTS warehouse;

SELECT
    schema_name
FROM information_schema.schemata
WHERE schema_name IN (
    'staging',
    'normalized',
    'warehouse'
)
ORDER BY schema_name;