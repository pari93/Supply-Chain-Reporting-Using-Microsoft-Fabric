-- Run once in WH_Evos_Gold before running the pipeline.

CREATE SCHEMA gold;
GO

DROP TABLE IF EXISTS gold.fact_terminal_movement;
GO
DROP TABLE IF EXISTS gold.dim_customer_contract;
GO
DROP TABLE IF EXISTS gold.dim_product;
GO
DROP TABLE IF EXISTS gold.dim_terminal;
GO
DROP TABLE IF EXISTS gold.dim_date;
GO

CREATE TABLE gold.dim_terminal (
    terminal_code VARCHAR(10) NOT NULL,
    terminal_name VARCHAR(100),
    country VARCHAR(80),
    port_hub VARCHAR(100),
    total_capacity_cbm INT,
    number_of_tanks INT,
    operational_since INT,
    specialty VARCHAR(200),
    source_url VARCHAR(500),
    last_modified_utc DATETIME2(6),
    dw_loaded_utc DATETIME2(6)
);
GO

CREATE TABLE gold.dim_product (
    product_code VARCHAR(20) NOT NULL,
    product_name VARCHAR(150),
    product_family VARCHAR(100),
    is_new_energy VARCHAR(20),
    typical_density_kg_m3 INT,
    last_modified_utc DATETIME2(6),
    dw_loaded_utc DATETIME2(6)
);
GO

CREATE TABLE gold.dim_customer_contract (
    contract_id VARCHAR(30) NOT NULL,
    customer_code VARCHAR(30),
    customer_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_country VARCHAR(80),
    terminal_code VARCHAR(10),
    product_code VARCHAR(20),
    contract_start_date DATE,
    contract_end_date DATE,
    reserved_capacity_cbm INT,
    storage_fee_eur_per_cbm_month FLOAT,
    handling_fee_eur_per_cbm FLOAT,
    contract_status VARCHAR(50),
    last_modified_utc DATETIME2(6),
    dw_loaded_utc DATETIME2(6)
);
GO

CREATE TABLE gold.dim_date (
    date_key DATE NOT NULL,
    year_number INT,
    month_number INT,
    month_name VARCHAR(20),
    day_of_month INT,
    iso_week INT,
    day_of_week_number INT,
    dw_loaded_utc DATETIME2(6)
);
GO

CREATE TABLE gold.fact_terminal_movement (
    movement_id VARCHAR(30) NOT NULL,
    movement_datetime_utc DATETIME2(6),
    planned_datetime_utc DATETIME2(6),
    terminal_code VARCHAR(10),
    product_code VARCHAR(20),
    contract_id VARCHAR(30),
    movement_type VARCHAR(80),
    transport_mode VARCHAR(80),
    volume_cbm FLOAT,
    movement_status VARCHAR(50),
    delay_hours FLOAT,
    delay_reason VARCHAR(120),
    last_modified_utc DATETIME2(6),
    movement_date DATE,
    is_completed INT,
    is_delayed INT,
    estimated_handling_fee_eur FLOAT,
    dw_loaded_utc DATETIME2(6)
);
GO
