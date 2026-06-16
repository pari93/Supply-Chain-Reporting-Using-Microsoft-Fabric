# Source setup click steps

## OneLake CSV source

1. Open `LH_Evos_BronzeSilver`.
2. Click **Files**.
3. Click **New folder** and create `source`.
4. Open `source`.
5. Click **New folder** and create `onelake_static`.
6. Upload:
   - `dim_terminal.csv`
   - `dim_product.csv`

Final path:

```text
Files/source/onelake_static/dim_terminal.csv
Files/source/onelake_static/dim_product.csv
```

## Dataverse source

1. Open `make.powerapps.com`.
2. Select the correct environment from the top-right environment selector.
3. Left menu: click **Tables**.
4. Click **Import** > **Import data from Excel or CSV**.
5. Select `customer_contracts.csv`.
6. Create a new table named `customer_contracts`.
7. Check that `last_modified_utc` is Date and Time.
8. Click **Import**.

## SharePoint List source

1. Open your SharePoint site.
2. Click **New** > **List**.
3. Choose **From CSV** or **From Excel**.
4. Upload `fact_terminal_movements.csv`.
5. Name the list `TerminalOperationsMovements`.
6. Confirm columns:
   - IDs and codes: Single line of text
   - `volume_cbm`, `delay_hours`: Number
   - `movement_datetime_utc`, `planned_datetime_utc`, `last_modified_utc`: Date and Time
7. Click **Create**.

## Add incremental movement rows

1. Open `fact_terminal_movements_incremental_rows_sharepoint_paste.tsv` in Excel.
2. Copy only data rows, not the header.
3. Open SharePoint list `TerminalOperationsMovements`.
4. Click **Edit in grid view**.
5. Click the first empty cell under `movement_id`.
6. Paste.
7. Click **Exit grid view**.

## Add one Dataverse contract update

1. Open `customer_contract_update.csv`.
2. Update the existing matching `contract_id` in Dataverse manually, or import the row.
3. Keep `last_modified_utc` newer than the current watermark.
