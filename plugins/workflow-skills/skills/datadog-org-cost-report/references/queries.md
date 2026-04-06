# SQL Query Templates

Ready-to-run Snowflake SQL for the `datadog-org-cost-report` skill.

Every query opens with the `org_scope` CTE. Choose Variant A or B based on whether
you have the parent org ID, and keep it consistent for the entire session.

**Replace before running:**
* `17166` — parent org ID (Variant A)
* `%-LMS` — name LIKE pattern (Variant B)
* `'2026-02-01'::DATE` — first day of the target billing month

---

## org_scope CTE (include at the top of every query)

**Variant A: by parent org ID (preferred)**
```sql
WITH org_scope AS (
  -- All orgs provisioned under the parent org
  -- MASTER_ORG_ID is more reliable than name patterns:
  -- it survives renames and avoids false matches
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166   -- replace: LMS=17166
)
```

**Variant B: by name pattern (fallback)**
```sql
WITH org_scope AS (
  -- Orgs whose name matches the LIKE pattern
  -- Use only when parent org ID is unknown
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE NAME LIKE '%-LMS'       -- replace: %-LMS, %-DEMO, %-PARTNER, etc.
)
```

---

## Query 1: Verify Scope — Total Org Count

Sanity-check total org count before filtering to active orgs.

```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166
)
SELECT
  COUNT(*)         AS total_orgs,
  COUNT(DISTINCT DATACENTER) AS datacenter_count
FROM org_scope;
```

---

## Query 2: Active Org Count + Plan Type Breakdown

Confirms active org count for the target month and shows plan type distribution.
"Active" = at least one billing dimension with PRODUCT_USAGE > 0.

```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166
),
active_orgs AS (
  SELECT DISTINCT u.ORG_ID
  FROM REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY u
  JOIN org_scope s ON s.ORG_ID = u.ORG_ID
  WHERE DATE_TRUNC('month', u.USAGE_DATE) = '2026-02-01'::DATE
    AND u.PRODUCT_USAGE > 0
)
SELECT
  (SELECT COUNT(*) FROM org_scope)   AS total_orgs_in_scope,
  COUNT(*)                           AS active_orgs,
  -- plan type check via cost model table (will show 'unsupported' for trial orgs)
  (SELECT COUNT(DISTINCT a.ORG_ID)
   FROM active_orgs a
   JOIN REPORTING.GENERAL.BYOD_COST_GA_V2_US1_MICHELADA c
     ON c.ORG_ID = a.ORG_ID
   WHERE c.PLAN_TYPE = 'trial'
  ) AS trial_orgs
FROM active_orgs;
```

---

## Query 3: Coverage Check — Billing Dimensions Present vs Excluded

Shows which billing dimensions have data in the target month and whether they have
a unit price. Use this to set expectations before cost computation.

```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166
)
SELECT
  u.PRIMARY_BILLING_DIMENSION,
  p.PRODUCT_NAME,
  p.PRICE_PER_UNIT,
  p.PRICING_NOTES,
  COUNT(DISTINCT u.ORG_ID)            AS org_count,
  SUM(u.PRODUCT_USAGE)                AS total_usage,
  CASE WHEN p.PRICE_PER_UNIT IS NOT NULL THEN 'included' ELSE 'excluded (no price)' END AS coverage
FROM REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY u
JOIN org_scope s ON s.ORG_ID = u.ORG_ID
LEFT JOIN REPORTING.GENERAL.DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION p
  ON p.PRODUCT_AGGREGATION = u.PRIMARY_BILLING_DIMENSION
WHERE DATE_TRUNC('month', u.USAGE_DATE) = '2026-02-01'::DATE
  AND u.PRODUCT_USAGE > 0
GROUP BY 1, 2, 3, 4
ORDER BY org_count DESC;
```

---

## Query 4: Monthly Cost Summary — All Products

Core cost computation. Returns total usage and estimated cost per billing dimension
for the target month across all orgs in scope.

```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166
),
usage AS (
  SELECT
    u.PRIMARY_BILLING_DIMENSION,
    SUM(u.PRODUCT_USAGE) AS total_usage
  FROM REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY u
  JOIN org_scope s ON s.ORG_ID = u.ORG_ID
  WHERE DATE_TRUNC('month', u.USAGE_DATE) = '2026-02-01'::DATE
    AND u.PRODUCT_USAGE > 0
  GROUP BY 1
)
SELECT
  u.PRIMARY_BILLING_DIMENSION,
  p.PRODUCT_NAME,
  p.PRICING_NOTES,
  u.total_usage,
  p.PRICE_PER_UNIT,
  -- Apply normalization based on dimension type:
  -- host-based: divide by 744 for avg, then multiply by price
  -- bytes-based: divide by 1073741824 for GB, then multiply by price
  -- count-based: multiply directly
  CASE
    WHEN u.PRIMARY_BILLING_DIMENSION LIKE '%hosts%'
      THEN ROUND((u.total_usage / 744.0) * p.PRICE_PER_UNIT, 2)
    WHEN u.PRIMARY_BILLING_DIMENSION IN ('logs ingested sum', 'live index logs ingested sum',
                                          'rehydrated logs ingested sum', 'apm ingested spans sum')
      THEN ROUND((u.total_usage / 1073741824.0) * p.PRICE_PER_UNIT, 2)
    WHEN u.PRIMARY_BILLING_DIMENSION = 'logs forwarded sum'
      THEN ROUND(u.total_usage * p.PRICE_PER_UNIT, 2)  -- price is per byte
    ELSE ROUND(u.total_usage * p.PRICE_PER_UNIT, 2)
  END AS estimated_cost_usd
FROM usage u
LEFT JOIN REPORTING.GENERAL.DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION p
  ON p.PRODUCT_AGGREGATION = u.PRIMARY_BILLING_DIMENSION
ORDER BY estimated_cost_usd DESC NULLS LAST;
```

---

## Query 5: Per-Org Cost Breakdown — Top 50

Shows the top 50 orgs by estimated total cost for the target month. Useful for
identifying high-consumption orgs and anomalies.

```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166
),
org_costs AS (
  SELECT
    s.ORG_ID,
    s.NAME,
    SUM(
      CASE
        WHEN u.PRIMARY_BILLING_DIMENSION LIKE '%hosts%'
          THEN (u.PRODUCT_USAGE / 744.0) * p.PRICE_PER_UNIT
        WHEN u.PRIMARY_BILLING_DIMENSION IN ('logs ingested sum', 'live index logs ingested sum',
                                              'rehydrated logs ingested sum', 'apm ingested spans sum')
          THEN (u.PRODUCT_USAGE / 1073741824.0) * p.PRICE_PER_UNIT
        WHEN u.PRIMARY_BILLING_DIMENSION = 'logs forwarded sum'
          THEN u.PRODUCT_USAGE * p.PRICE_PER_UNIT
        WHEN p.PRICE_PER_UNIT IS NOT NULL
          THEN u.PRODUCT_USAGE * p.PRICE_PER_UNIT
        ELSE 0
      END
    ) AS estimated_cost_usd
  FROM REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY u
  JOIN org_scope s ON s.ORG_ID = u.ORG_ID
  LEFT JOIN REPORTING.GENERAL.DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION p
    ON p.PRODUCT_AGGREGATION = u.PRIMARY_BILLING_DIMENSION
  WHERE DATE_TRUNC('month', u.USAGE_DATE) = '2026-02-01'::DATE
    AND u.PRODUCT_USAGE > 0
  GROUP BY s.ORG_ID, s.NAME
)
SELECT *
FROM org_costs
ORDER BY estimated_cost_usd DESC
LIMIT 50;
```

---

## Query 6: Product Mix Trend — 6-Month Rolling (Metabase)

Stacked bar chart of estimated cost by billing dimension over the last 6 months.
Useful for tracking which products drive cost growth.

```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166
),
monthly_usage AS (
  SELECT
    DATE_TRUNC('month', u.USAGE_DATE)  AS month,
    u.PRIMARY_BILLING_DIMENSION,
    p.PRODUCT_NAME,
    SUM(u.PRODUCT_USAGE)               AS total_usage,
    p.PRICE_PER_UNIT
  FROM REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY u
  JOIN org_scope s ON s.ORG_ID = u.ORG_ID
  LEFT JOIN REPORTING.GENERAL.DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION p
    ON p.PRODUCT_AGGREGATION = u.PRIMARY_BILLING_DIMENSION
  WHERE u.USAGE_DATE >= DATEADD('month', -6, DATE_TRUNC('month', CURRENT_DATE()))
    AND u.PRODUCT_USAGE > 0
  GROUP BY 1, 2, 3, 5
)
SELECT
  month,
  COALESCE(PRODUCT_NAME, PRIMARY_BILLING_DIMENSION) AS product,
  ROUND(
    CASE
      WHEN PRIMARY_BILLING_DIMENSION LIKE '%hosts%'
        THEN (total_usage / 744.0) * PRICE_PER_UNIT
      WHEN PRIMARY_BILLING_DIMENSION IN ('logs ingested sum', 'live index logs ingested sum',
                                          'rehydrated logs ingested sum', 'apm ingested spans sum')
        THEN (total_usage / 1073741824.0) * PRICE_PER_UNIT
      WHEN PRIMARY_BILLING_DIMENSION = 'logs forwarded sum'
        THEN total_usage * PRICE_PER_UNIT
      WHEN PRICE_PER_UNIT IS NOT NULL
        THEN total_usage * PRICE_PER_UNIT
      ELSE NULL
    END, 2
  ) AS estimated_cost_usd
FROM monthly_usage
ORDER BY month, estimated_cost_usd DESC NULLS LAST;
```

---

## Query 7: Active Org Count Trend — 12-Month Rolling (Metabase)

Line chart of distinct active org count per month over the last 12 months.
Good for growth trend visualization.

```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166
)
SELECT
  DATE_TRUNC('month', u.USAGE_DATE) AS month,
  COUNT(DISTINCT u.ORG_ID)          AS active_orgs
FROM REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY u
JOIN org_scope s ON s.ORG_ID = u.ORG_ID
WHERE u.USAGE_DATE >= DATEADD('month', -12, DATE_TRUNC('month', CURRENT_DATE()))
  AND u.PRODUCT_USAGE > 0
GROUP BY 1
ORDER BY 1;
```

---

## Query 8: Drill-Down by Sub-Group (e.g., event prefix)

Break down cost by a name-based sub-group within the parent org scope. Replace the
SPLIT pattern with the actual prefix structure for the event.

```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166
),
subgroup AS (
  -- Extract sub-group label from org name (e.g., 'aws-hackathon-0226' from 'aws-hackathon-0226-user-001-LMS')
  -- Adjust the SPLIT_PART logic based on actual naming convention
  SELECT
    ORG_ID,
    NAME,
    SPLIT_PART(NAME, '-', 1) || '-' || SPLIT_PART(NAME, '-', 2) || '-' || SPLIT_PART(NAME, '-', 3) AS event_prefix
  FROM org_scope
)
SELECT
  sg.event_prefix,
  COUNT(DISTINCT sg.ORG_ID)   AS org_count,
  COUNT(DISTINCT CASE WHEN u.PRODUCT_USAGE > 0 THEN sg.ORG_ID END) AS active_orgs,
  SUM(
    CASE
      WHEN u.PRIMARY_BILLING_DIMENSION LIKE '%hosts%'
        THEN (u.PRODUCT_USAGE / 744.0) * p.PRICE_PER_UNIT
      WHEN u.PRIMARY_BILLING_DIMENSION IN ('logs ingested sum', 'live index logs ingested sum',
                                            'rehydrated logs ingested sum')
        THEN (u.PRODUCT_USAGE / 1073741824.0) * p.PRICE_PER_UNIT
      WHEN p.PRICE_PER_UNIT IS NOT NULL
        THEN u.PRODUCT_USAGE * p.PRICE_PER_UNIT
      ELSE 0
    END
  ) AS estimated_cost_usd
FROM subgroup sg
LEFT JOIN REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY u
  ON u.ORG_ID = sg.ORG_ID
  AND DATE_TRUNC('month', u.USAGE_DATE) = '2026-02-01'::DATE
LEFT JOIN REPORTING.GENERAL.DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION p
  ON p.PRODUCT_AGGREGATION = u.PRIMARY_BILLING_DIMENSION
GROUP BY 1
ORDER BY estimated_cost_usd DESC NULLS LAST;
```
