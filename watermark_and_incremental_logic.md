# Watermark and incremental logic

## Watermark file

```text
Files/bronze/_watermark/watermark.json
```

Example:

```json
{
  "dim_terminal": "2026-06-01T08:00:00Z",
  "dim_product": "2026-06-01T08:00:00Z",
  "customer_contracts": "2026-06-11T02:00:00Z",
  "terminal_movements": "2026-06-16T10:40:00Z"
}
```

## Source rule

Every source table/file has `last_modified_utc`.

The pipeline loads rows where:

```text
source.last_modified_utc > watermark[source_name]
```

## Bronze rule

Bronze appends incoming raw records.

## Silver rule

Silver keeps one current row per primary key.

| Table | Primary key |
|---|---|
| silver_terminal | terminal_code |
| silver_product | product_code |
| silver_contract | contract_id |
| silver_movement | movement_id |
| silver_date | date_key |

## Gold rule

Gold uses MERGE from Silver into Warehouse tables.

## Idempotency rule

If the pipeline is rerun:

- Bronze may receive repeated raw rows if a failure happened before watermark update.
- Silver keeps only the latest row by primary key.
- Gold updates or inserts by primary key.
- Report counts remain stable.
