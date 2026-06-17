# Fabric pipeline click steps

## 1. Create the pipeline

1. Open Fabric workspace.
2. Click **+ New item**.
3. Search **Data pipeline**.
4. Name it `PL_Evos_Batch_Load`.
5. Click **Create**.

## 2. Add NB_00 activity

1. In the pipeline canvas, click **Activities**.
2. Search **Notebook**.
3. Click **Notebook** to add it.
4. Rename it `NB_00_Fetch_Watermark`.
5. In **Settings**, choose notebook `NB_00_Fetch_Watermark_And_Static_Ingest`.

## 3. Add If Condition

1. Click **Activities**.
2. Search **If Condition**.
3. Add it after `NB_00_Fetch_Watermark`.
4. Connect `NB_00_Fetch_Watermark` to the If activity using the success arrow.
5. In **Settings**, use this expression:

```text
@equals(json(activity('NB_00_Fetch_Watermark').output.result.exitValue).run_copy_sources, true)
```

## 4. Add Dataverse Copy activity inside True branch

1. Open the If activity.
2. Click the **True** branch.
3. Click **Activities** > **Copy data**.
4. Rename it `Copy_Dataverse_Contracts_To_Bronze`.
5. Source:
   - Connection type: **Dataverse**
   - Table: `customer_contracts`
   - Filter rows:

```text
@concat('last_modified_utc gt ', json(activity('NB_00_Fetch_Watermark').output.result.exitValue).customer_contracts)
```

6. Destination:
   - Destination type: **Lakehouse**
   - Lakehouse: `LH_Evos_BronzeSilver`
   - Table: `bronze_contract_raw`
   - Table action: **Append**

## 5. Add SharePoint Copy activity inside True branch

1. In the same True branch, add another **Copy data** activity.
2. Rename it `Copy_SharePoint_Movements_To_Bronze`.
3. Source:
   - Connection type: **SharePoint Online List**
   - Site URL: your SharePoint site URL
   - List: `TerminalOperationsMovements`
   - Filter rows:

```text
@concat('last_modified_utc gt ''', json(activity('NB_00_Fetch_Watermark').output.result.exitValue).terminal_movements, '''')
```

4. Destination:
   - Destination type: **Lakehouse**
   - Lakehouse: `LH_Evos_BronzeSilver`
   - Table: `bronze_movement_raw`
   - Table action: **Append**

## 6. Add NB_01 activity

1. Go back to the main pipeline canvas.
2. Add a **Notebook** activity after the If activity.
3. Rename it `NB_01_Bronze_To_Silver`.
4. In **Settings**, choose notebook `NB_01_Bronze_To_Silver`.
5. Connect the If activity success arrow to this notebook.

## 7. Add NB_02 activity

1. Add a **Notebook** activity after `NB_01_Bronze_To_Silver`.
2. Rename it `NB_02_Silver_To_Gold`.
3. In **Settings**, choose notebook `NB_02_Silver_To_Gold_Warehouse`.
4. Make sure this notebook is created as a T-SQL notebook attached to `WH_Evos_Gold`.

## 8. Save and run

1. Click **Save**.
2. Click **Run**.
3. After completion, open `WH_Evos_Gold` and run `02_validation_queries.sql`.
