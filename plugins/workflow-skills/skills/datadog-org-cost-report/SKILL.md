---
name: datadog-org-cost-report
description: Estimate Datadog usage cost for a set of orgs matched by name pattern (e.g., -LMS, -DEMO, -PARTNER) from Snowflake. Use when asked about the cost of LMS orgs, training sandbox costs, demo org costs, curriculum org usage, or generating periodic org cost reports for any internal org group. Accepts an org name suffix/pattern or parent org ID as input. Outputs a markdown report with cost breakdown by product plus Metabase SQL queries.
---

# Datadog Org Cost Report

Estimate Datadog list-price usage cost for any group of internal orgs, queried from
Snowflake. Encodes the workflow and query patterns used to produce the February 2026
LMS org cost analysis (~$775K for ~7,567 active orgs).

---

## Inputs

Collect two pieces of information before running queries:

**1. Org group identifier (one of two mutually exclusive options):**

* `parent_org_id` **(preferred)**: filter by `DIM_ORG.MASTER_ORG_ID`
  (e.g., `17166` for LMS/curriculum orgs). More reliable than name patterns:
  covers renamed orgs, avoids false matches on overlapping suffixes.
* `org_name_pattern` **(fallback)**: SQL `LIKE` pattern applied to `DIM_ORG.NAME`
  (e.g., `%-LMS`, `%-DEMO`, `%-PARTNER`). Use when the parent org ID is unknown.

**2. `month` (optional):** target billing month in `YYYY-MM` format.
Defaults to the most recent complete calendar month (UTC).

**Known parent org IDs:**
* `17166` = LMS/curriculum orgs (the org provisioned by the training platform)

---

## Scope CTE Pattern

Every query in a session **must** open with the same `org_scope` CTE so that the org
group definition is consistent across all queries. Two variants — pick one and use it
throughout the session:

**Variant A: by parent org ID (preferred)**
```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE MASTER_ORG_ID = 17166   -- replace with the actual parent org ID
)
```

**Variant B: by name pattern (fallback)**
```sql
WITH org_scope AS (
  SELECT DISTINCT ID AS ORG_ID, NAME, DATACENTER
  FROM REPORTING.GENERAL.DIM_ORG
  WHERE NAME LIKE '%-LMS'       -- replace with the actual LIKE pattern
)
```

Ready-to-run SQL for all workflow phases is in `references/queries.md`.

---

## Core Principles

1. **Trial/free plans are not supported by the GA cost model.** Most internal orgs
   are on trial or free plans. `BYOD_COST_GA_V2_US1_MICHELADA` returns "unsupported"
   for these orgs. Use list prices from `DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION`
   for all cost estimates instead.

1. **Host costs use monthly average as a lower-bound proxy.** `FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY`
   stores cumulative hourly host snapshots (`host_count_monthly_sum`). Datadog's
   actual billing uses the 99th percentile. Dividing the monthly sum by 744 (hours in
   a 31-day month) yields an average, which is a conservative lower bound.

1. **Estimates are list prices only.** Enterprise customers receive significant
   discounts. The list-price total represents "retail value," not invoice cost.

1. **Not all products have prices in the startup pricing table.** SIEM, Flex Logs,
   and Serverless are excluded from cost estimates (no matching unit price). Include
   their raw usage quantities in the report but mark them as "no price available."

---

## Quick Start

**Step 1: Load Snowflake MCP**
Use `ToolSearch` to load the Snowflake MCP server before running any queries.

**Step 2: Build org_scope; get active org count + plan type breakdown**
Use Query 2 from `references/queries.md`. Confirms scope and flags plan distribution.

**Step 3: Coverage check**
Use Query 3 to see which billing dimensions are present in the data and which
are excluded (no unit price). Sets expectations before computing costs.

**Step 4: Query monthly usage and apply unit prices**
Use Query 4 (monthly cost summary) from `references/queries.md`.

**Step 5: Write report**
Write results to `reports/org-cost-{label}-{YYYY-MM}.md` relative to the project
root. Use `{label}` as a short identifier for the org group (e.g., `lms`, `demo`).
Include the mandatory caveats block (see below).

---

## Mandatory Report Caveats

Every generated report **must** include this block (adapt values as needed):

```markdown
## Caveats

* **List prices only.** Enterprise customers receive significant discounts.
  This estimate reflects retail/list pricing, not actual invoice cost.
* **Average vs 99th-percentile hosts.** Host costs are estimated using monthly
  average (sum / 744 hours). Datadog bills on 99th percentile, which is higher.
  These figures are a lower bound.
* **Unsupported products excluded.** SIEM, Flex Logs, and Serverless do not
  have unit prices in the startup pricing table and are excluded from cost totals.
* **US1 scope.** `BYOD_COST_GA_V2_US1_MICHELADA` covers US1 only. Usage from
  EU1, AP1, US3, and US5 orgs may be incomplete or missing.
* **Pricing source:** `REPORTING.GENERAL.DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION`
* **Usage source:** `REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY`
```

---

## Key Tables

| Table | Schema | Purpose |
|---|---|---|
| `DIM_ORG` | `REPORTING.GENERAL` | Org metadata: `ID`, `NAME`, `MASTER_ORG_ID`, `DATACENTER` |
| `FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY` | `REPORTING.GENERAL` | Monthly usage by org and billing dimension; join on `ORG_ID = DIM_ORG.ID` |
| `DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION` | `REPORTING.GENERAL` | Unit prices by `PRODUCT_AGGREGATION`; join on `PRODUCT_AGGREGATION = PRIMARY_BILLING_DIMENSION` |
| `BYOD_COST_GA_V2_US1_MICHELADA` | `REPORTING.GENERAL` | GA V2 cost model; returns "unsupported" for trial/free orgs -- use for plan type confirmation only |

---

## Report Output Format

```markdown
# Datadog Org Cost Report: {Label} Orgs - {Month}

## Summary
| Metric | Value |
|---|---|
| Total orgs in scope | X |
| Active orgs (usage > 0) | X |
| Total estimated cost (list price) | $X |
| Cost per active org | $X |

## Cost Breakdown by Product
| Product | Metric | Usage | Unit Price | Est. Cost |
|---|---|---|---|---|
| Infrastructure Monitoring | avg hosts | X | $18/host | $X |
| APM | avg hosts | X | $36/host | $X |
| ... | ... | ... | ... | ... |
| **Total** | | | | **$X** |

## Products Without Pricing
| Product | Usage | Note |
|---|---|---|
| SIEM | X events | No unit price available |
| Flex Logs | X events | No unit price available |
| Serverless | X invocations | No unit price available |

## Caveats
[mandatory caveats block]

## Metabase Queries
[inline SQL for 6-month trend, per-org breakdown, product mix]
```

---

## References

* `references/pricing.md` -- static unit price table from `DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION`
* `references/queries.md` -- ready-to-run SQL templates for all workflow phases
* `references/definitions.md` -- canonical metric definitions (active org, month boundary, host proxy, etc.)
