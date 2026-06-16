-- Use these checks after the pipeline run.

SELECT 'gold.dim_terminal' AS table_name, COUNT(*) AS row_count FROM gold.dim_terminal
UNION ALL
SELECT 'gold.dim_product', COUNT(*) FROM gold.dim_product
UNION ALL
SELECT 'gold.dim_customer_contract', COUNT(*) FROM gold.dim_customer_contract
UNION ALL
SELECT 'gold.dim_date', COUNT(*) FROM gold.dim_date
UNION ALL
SELECT 'gold.fact_terminal_movement', COUNT(*) FROM gold.fact_terminal_movement;

SELECT TOP 20 *
FROM gold.fact_terminal_movement
ORDER BY movement_datetime_utc DESC;
