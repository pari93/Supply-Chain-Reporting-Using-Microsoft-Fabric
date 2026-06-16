# Architecture

## Bronze

Bronze tables store raw source changes.

```text
bronze_terminal_raw
bronze_product_raw
bronze_contract_raw
bronze_movement_raw
```

Bronze is append-only. Repeated rows are acceptable because Silver keeps the latest version by primary key.

## Silver

Silver tables store clean current records.

```text
silver_terminal
silver_product
silver_contract
silver_movement
silver_date
```

Silver applies:

- remove null primary keys
- uppercase business codes
- cast dates and numbers
- remove duplicates by primary key
- keep latest record by `last_modified_utc`
- merge into current Silver table

## Gold

Gold tables are in Fabric Warehouse.

```text
gold.dim_terminal
gold.dim_product
gold.dim_customer_contract
gold.dim_date
gold.fact_terminal_movement
```

Gold is loaded with T-SQL MERGE from Silver tables.
