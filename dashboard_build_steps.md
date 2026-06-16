# Power BI Dashboard Build Steps

## 1. Objective

Create a clean starter dashboard for the Evos-style Fabric project.

The report should show:

- terminal movement volume
- movement count and completion status
- delays
- estimated handling revenue
- reserved customer capacity
- basic data freshness

Keep the design simple:

- use a light background
- use one professional font such as Segoe UI
- keep visuals aligned
- avoid too many colors
- avoid too many visuals on one page

Recommended pages:

1. Executive Overview
2. Operations Detail
3. Contracts and Capacity
4. Data Freshness

---

## 2. Load tables into Power BI

Connect Power BI Desktop to the Fabric Warehouse and load these Gold tables:

- `gold.dim_terminal`
- `gold.dim_product`
- `gold.dim_customer_contract`
- `gold.dim_date`
- `gold.fact_terminal_movement`

After loading, rename them in Power BI to:

- `gold_dim_terminal`
- `gold_dim_product`
- `gold_dim_customer_contract`
- `gold_dim_date`
- `gold_fact_terminal_movement`

---

## 3. Create relationships

Create these relationships in Model view:

```text
gold_dim_terminal[terminal_code] → gold_fact_terminal_movement[terminal_code]
gold_dim_terminal[terminal_code] → gold_dim_customer_contract[terminal_code]
gold_dim_product[product_code] → gold_fact_terminal_movement[product_code]
gold_dim_date[date_key] → gold_fact_terminal_movement[movement_date]
```

Use:

- One-to-many relationship
- Single direction filtering
- Dimensions on the one side
- Fact table on the many side

This gives you a simple star schema.

---

## 4. Create measures

Create these measures under the fact table or in a separate measure table.

```DAX
Total Volume cbm =
SUM ( gold_fact_terminal_movement[volume_cbm] )
```

```DAX
Movement Count =
COUNTROWS ( gold_fact_terminal_movement )
```

```DAX
Completed Movement Count =
CALCULATE (
    [Movement Count],
    gold_fact_terminal_movement[movement_status] = "Completed"
)
```

```DAX
Delayed Movement Count =
CALCULATE (
    [Movement Count],
    gold_fact_terminal_movement[is_delayed] = 1
)
```

```DAX
Delay Rate % =
DIVIDE ( [Delayed Movement Count], [Movement Count] )
```

```DAX
Average Delay Hours =
AVERAGE ( gold_fact_terminal_movement[delay_hours] )
```

```DAX
Estimated Handling Revenue EUR =
SUM ( gold_fact_terminal_movement[estimated_handling_fee_eur] )
```

```DAX
Reserved Capacity cbm =
CALCULATE (
    SUM ( gold_dim_customer_contract[reserved_capacity_cbm] ),
    TREATAS (
        VALUES ( gold_dim_terminal[terminal_code] ),
        gold_dim_customer_contract[terminal_code]
    ),
    TREATAS (
        VALUES ( gold_dim_product[product_code] ),
        gold_dim_customer_contract[product_code]
    )
)
```

```DAX
Total Terminal Capacity cbm =
SUM ( gold_dim_terminal[total_capacity_cbm] )
```

```DAX
Reserved Capacity % =
DIVIDE ( [Reserved Capacity cbm], [Total Terminal Capacity cbm] )
```

```DAX
Latest Source Modified UTC =
MAX ( gold_fact_terminal_movement[last_modified_utc] )
```

```DAX
Latest Warehouse Load UTC =
MAX ( gold_fact_terminal_movement[dw_loaded_utc] )
```

## 5. Format measures

Use simple formats:

| Measure | Format |
|---|---|
| Total Volume cbm | Whole number |
| Movement Count | Whole number |
| Completed Movement Count | Whole number |
| Delayed Movement Count | Whole number |
| Delay Rate % | Percentage |
| Average Delay Hours | Decimal number |
| Estimated Handling Revenue EUR | Currency / Euro |
| Reserved Capacity cbm | Whole number |
| Total Terminal Capacity cbm | Whole number |
| Reserved Capacity % | Percentage |
| Latest Source Modified UTC | Date/time |
| Latest Warehouse Load UTC | Date/time |

Keep decimal places low. For example, use 0 decimals for volume and revenue, and 1 decimal for percentages or delay hours.

---

## 6. General design style

Use this simple style throughout the report:

- Font: Segoe UI
- Background: light grey or white
- Visual cards: white background
- Text: dark grey or black
- Main chart color: blue
- Positive/completed status: green
- Warning/delay status: amber or red
- Keep titles short and business-friendly

Good visual titles:

- Total Volume by Terminal
- Product Mix
- Movement Trend
- Delay Rate by Terminal
- Reserved Capacity by Customer

Avoid technical titles such as:

- Chart 1
- Query Output
- Fact Table Data

---

# Page 1: Executive Overview

## 7. Purpose

This page is for a quick management-level summary.

It should show:

- total volume
- total movements
- estimated revenue
- delay rate
- which terminals have the most activity
- which products are moving
- volume trend over time

## 8. Add slicers

Place slicers at the top of the page.

Use these slicers:

- Terminal: `gold_dim_terminal[terminal_name]`
- Product Family: `gold_dim_product[product_family]`
- Date: `gold_dim_date[date_key]`

Use dropdown slicers for Terminal and Product Family.

Use a date range slicer for Date.

## 9. Add card visuals

Create 4 card visuals.

Use these measures:

| Card | Measure |
|---|---|
| Total Volume | `[Total Volume cbm]` |
| Movements | `[Movement Count]` |
| Handling Revenue | `[Estimated Handling Revenue EUR]` |
| Delay Rate | `[Delay Rate %]` |

Position suggestion:

- Put the slicers across the top.
- Put the 4 cards below the slicers.
- Keep the cards equal size and aligned.
- Use larger font for the card value and smaller font for the label.

## 10. Add main charts

Add these visuals below the cards:

### Visual 1: Total Volume by Terminal

Visual type:

- Clustered bar chart

Fields:

- Axis: `gold_dim_terminal[terminal_name]`
- Values: `[Total Volume cbm]`

Format:

- Sort descending by volume.
- Use blue as the main color.
- Turn on data labels if the chart is still readable.

### Visual 2: Product Mix

Visual type:

- Donut chart or bar chart

Fields:

- Legend/Axis: `gold_dim_product[product_family]`
- Values: `[Total Volume cbm]`

Format:

- Use donut chart only if there are few product groups.
- If labels look crowded, use a bar chart instead.

### Visual 3: Movement Trend

Visual type:

- Line chart

Fields:

- X-axis: `gold_dim_date[date_key]`
- Y-axis: `[Total Volume cbm]`

Format:

- Use this to show daily movement trend.
- Keep data labels off if there are many dates.

### Visual 4: Delay Rate by Terminal

Visual type:

- Column chart or bar chart

Fields:

- Axis: `gold_dim_terminal[terminal_name]`
- Values: `[Delay Rate %]`

Format:

- Use amber/red only for delay-related visuals.
- Keep the title clear: `Delay Rate by Terminal`.

---

# Page 2: Operations Detail

## 11. Purpose

This page is for operational analysis.

It should answer:

- What type of movements are happening?
- Which transport modes are used?
- Which movements are delayed?
- What are the delay reasons?

## 12. Add slicers

Use:

- Terminal
- Product Family
- Date

Keep slicers in the same position as Page 1 for consistency.

## 13. Add visuals

### Visual 1: Volume by Movement Type

Visual type:

- Bar chart

Fields:

- Axis: `gold_fact_terminal_movement[movement_type]`
- Values: `[Total Volume cbm]`

### Visual 2: Movements by Transport Mode

Visual type:

- Column chart

Fields:

- Axis: `gold_fact_terminal_movement[transport_mode]`
- Values: `[Movement Count]`

### Visual 3: Average Delay by Reason

Visual type:

- Bar chart

Fields:

- Axis: `gold_fact_terminal_movement[delay_reason]`
- Values: `[Average Delay Hours]`

Filter out blank or no-delay reasons if they make the chart noisy.

### Visual 4: Movement Details Table

Visual type:

- Table

Fields:

- `movement_id`
- `gold_dim_terminal[terminal_name]`
- `gold_dim_product[product_name]`
- `movement_type`
- `transport_mode`
- `movement_datetime_utc`
- `volume_cbm`
- `movement_status`
- `delay_hours`
- `delay_reason`

Format:

- Keep table font small but readable.
- Sort by latest movement date/time.
- Use conditional formatting on delay hours if you want to highlight delayed movements.

---

# Page 3: Contracts and Capacity

## 14. Purpose

This page connects customer contracts to terminal capacity.

It should answer:

- How much capacity is reserved?
- Which customers reserve the most capacity?
- Which terminals have the most total capacity?
- What is the reserved capacity percentage?

## 15. Add card visuals

Use these cards:

| Card | Measure |
|---|---|
| Reserved Capacity | `[Reserved Capacity cbm]` |
| Total Terminal Capacity | `[Total Terminal Capacity cbm]` |
| Reserved Capacity % | `[Reserved Capacity %]` |

Optional extra measure:

```DAX
Contract Count =
DISTINCTCOUNT ( gold_dim_customer_contract[contract_id] )
```

Add it as a fourth card if needed.

## 16. Add charts

### Visual 1: Reserved Capacity by Customer

Visual type:

- Bar chart

Fields:

- Axis: `gold_dim_customer_contract[customer_name]`
- Values: `[Reserved Capacity cbm]`

Sort descending.

### Visual 2: Capacity by Terminal

Visual type:

- Bar chart or column chart

Fields:

- Axis: `gold_dim_terminal[terminal_name]`
- Values: `[Total Terminal Capacity cbm]`

Use bar chart if terminal names overlap.

### Visual 3: Reserved Capacity by Terminal and Product

Visual type:

- Matrix

Rows:

- `gold_dim_terminal[terminal_name]`

Columns:

- `gold_dim_product[product_family]`

Values:

- `[Reserved Capacity cbm]`

Format:

- Keep totals on.
- Use this as a compact cross-tab view.

---

# Page 4: Data Freshness

## 17. Purpose

This page shows that the pipeline is working and gives trust in the data.

It should answer:

- When was the source last updated?
- When was the Warehouse last loaded?
- How many movement rows are available?

## 18. Add card visuals

Use these cards:

| Card | Measure |
|---|---|
| Latest Source Update | `[Latest Source Modified UTC]` |
| Latest Warehouse Load | `[Latest Warehouse Load UTC]` |
| Movement Count | `[Movement Count]` |

## 19. Add latest records table

Visual type:

- Table

Fields:

- `movement_id`
- `terminal_code`
- `source_system`
- `last_modified_utc`
- `dw_loaded_utc`

Sort descending by `last_modified_utc`.

## 20. Add lineage text

Add a simple text box:

```text
Data lineage:
Dataverse, SharePoint and OneLake CSV data land in Bronze.
Notebook transformations clean and merge data into Silver.
Warehouse Gold tables support Power BI reporting.
```

This is useful when explaining the project.

---

# 21. Final formatting checklist

Before finishing the report, check:

- All pages use the same font.
- All pages have a clear title.
- Slicers are positioned consistently.
- Cards are aligned and similar in size.
- Visual titles are business-friendly.
- There are not too many colors.
- Red/amber colors are used only for warning or delay.
- Numbers are formatted properly.
- Percentages show as percentages.
- Currency shows as EUR.
- Date slicers filter all pages correctly.
- Terminal and product slicers filter all visuals.
- Tables are readable.
- No unnecessary technical columns are visible to users.

---

# 22. Suggested explanation for the interview

Use this:

```text
I created a simple Power BI dashboard on top of the Fabric Warehouse Gold layer.
The model follows a star schema with terminal, product, contract and date dimensions around a terminal movement fact table.
The Overview page shows management KPIs such as volume, movement count, revenue and delay rate.
The Operations page helps analyze movement types, transport modes and delays.
The Contracts page connects reserved customer capacity to terminal capacity.
The Freshness page shows source and warehouse load timestamps so users can trust the data.
```

Key point:

```text
The report uses reusable DAX measures and Gold-layer tables, instead of building calculations directly inside visuals. This keeps the dashboard simple, consistent and easier to maintain.
```
