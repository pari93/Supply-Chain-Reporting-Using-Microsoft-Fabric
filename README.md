# Evos Terminal BI Prototype

Simple Microsoft Fabric batch BI project using OneLake CSV, Dataverse, SharePoint List, Lakehouse notebooks, Fabric Warehouse, and Power BI.

## Architecture

```text
OneLake CSV static files
Dataverse customer contracts
SharePoint terminal movements
        ↓
Bronze raw Delta tables
        ↓
Silver current Delta tables
        ↓
Gold Fabric Warehouse tables
        ↓
Power BI dashboard
```

## Object names

```text
Workspace: ws-evos-terminal-bi
Lakehouse: LH_Evos_BronzeSilver
Warehouse: WH_Evos_Gold
Pipeline: PL_Evos_Batch_Load
Notebook: NB_00_Fetch_Watermark_And_Static_Ingest
Notebook: NB_01_Bronze_To_Silver
Notebook: NB_02_Silver_To_Gold_Warehouse
```

## Source-to-table mapping

| Source | Source object | Bronze table | Silver table | Gold table |
|---|---|---|---|---|
| OneLake CSV | dim_terminal.csv | bronze_terminal_raw | silver_terminal | gold.dim_terminal |
| OneLake CSV | dim_product.csv | bronze_product_raw | silver_product | gold.dim_product |
| Dataverse | customer_contracts | bronze_contract_raw | silver_contract | gold.dim_customer_contract |
| SharePoint List | TerminalOperationsMovements | bronze_movement_raw | silver_movement | gold.fact_terminal_movement |
| Notebook | generated dates | - | silver_date | gold.dim_date |

## Watermark file

Watermark is stored here in the Lakehouse Files section:

```text
Files/bronze/_watermark/watermark.json
```

The file stores the latest successful `last_modified_utc` for each source.

## Build order

1. Create Fabric workspace, Lakehouse, Warehouse, and notebooks.
2. Upload `01_source_data/onelake_static` to `Files/source/onelake_static` in the Lakehouse.
3. Import `customer_contracts.csv` into Dataverse.
4. Import `fact_terminal_movements.csv` into a SharePoint List.
5. Run `03_fabric_warehouse_sql/01_create_gold_tables.sql` once in the Warehouse.
6. Create pipeline `PL_Evos_Batch_Load`.
7. Add notebook activity `NB_00_Fetch_Watermark_And_Static_Ingest`.
8. Add If Condition activity.
9. Inside True branch, add two Copy activities:
   - Dataverse to `bronze_contract_raw`
   - SharePoint List to `bronze_movement_raw`
10. Add notebook activity `NB_01_Bronze_To_Silver`.
11. Add notebook activity `NB_02_Silver_To_Gold_Warehouse`.
12. Connect Power BI to `WH_Evos_Gold`.

## Pipeline logic

```text
NB_00: reads watermark JSON and ingests new static CSV rows into Bronze
If Condition: continues when watermark read is successful
Copy Dataverse: copies contract rows where last_modified_utc > watermark
Copy SharePoint: copies movement rows where last_modified_utc > watermark
NB_01: cleans Bronze and upserts into Silver
NB_02: merges Silver into Gold Warehouse
```

## Expected counts

Initial run:

```text
gold.dim_terminal: 8
gold.dim_product: 9
gold.dim_customer_contract: 17
gold.dim_date: 365
gold.fact_terminal_movement: 500
```

After adding 30 movement rows:

```text
gold.fact_terminal_movement: 530
```

## Key design decisions

- Bronze is append-only raw history.
- Silver is current-state, cleaned, deduplicated and upserted by primary key.
- Gold is a reporting-ready warehouse star schema.
- Watermark updates only after Silver succeeds.
- Re-running the pipeline does not duplicate Silver or Gold rows.

