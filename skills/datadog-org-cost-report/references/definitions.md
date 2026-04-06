# Canonical Metric Definitions

Definitions used consistently by every query in the `datadog-org-cost-report` skill.
When in doubt about how a term is computed, this file is the source of truth.

---

## Active Org

An org with `PRODUCT_USAGE > 0` for at least one billing dimension in the target month.

```sql
-- Count active orgs
SELECT COUNT(DISTINCT u.ORG_ID)
FROM REPORTING.GENERAL.FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY u
JOIN org_scope s ON s.ORG_ID = u.ORG_ID
WHERE DATE_TRUNC('month', u.USAGE_DATE) = DATE_TRUNC('month', '2026-02-01'::DATE)
  AND u.PRODUCT_USAGE > 0
```

---

## Month Boundary

Use `DATE_TRUNC('month', ...)` (UTC) as the month boundary for all filters. A
"complete" month is one where the month-end has passed in UTC.

```sql
-- February 2026
DATE_TRUNC('month', USAGE_DATE) = '2026-02-01'::DATE

-- Most recent complete calendar month (dynamic)
DATE_TRUNC('month', DATEADD('month', -1, CURRENT_DATE()))
```

---

## Billable Host Proxy (Average)

`FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY` stores hourly host snapshots aggregated into a
monthly sum (`host_count_monthly_sum` or `PRODUCT_USAGE` for host-based dimensions).
Datadog's actual billing uses the **99th percentile** of hourly snapshots.

Since the 99p is not directly available in the monthly table, divide the monthly sum
by the number of hours in the billing period as a lower-bound approximation:

```
avg_hosts = host_count_monthly_sum ÷ 744
```

744 = 31 days × 24 hours. For February, use 672 (28 days × 24). In practice, 744 is
used as a consistent denominator across all months to make month-over-month comparisons
consistent and slightly conservative.

**Host-based billing dimensions:** `infra hosts 99p`, `apm hosts 99p`,
`profiling hosts 99p`, `database monitoring hosts 99p`, `cspm hosts 99p`,
`csm enterprise hosts 99p`, `cws hosts 99p`, `npm hosts 99p`.

---

## Included Products (13 billing dimensions with known unit prices)

These dimensions have matching entries in `DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION`
and are included in cost estimates:

1. `infra hosts 99p` — Infrastructure Monitoring ($18/host)
1. `apm hosts 99p` — APM ($36/host)
1. `containers avg` — Container Monitoring ($1.35/container)
1. `custom metrics avg` — Custom Metrics ($0.05/metric)
1. `live index logs indexed sum` — Log Management 15-day ($2.55/1M logs)
1. `live index logs ingested sum` — Log Management Ingestion ($0.10/GB)
1. `logs ingested sum` — Log Ingestion ($0.10/GB)
1. `logs forwarded sum` — Log Forwarding ($0.25/GB, stored as $2.5e-10/byte)
1. `rehydrated logs indexed sum` — Log Rehydration ($1.50/1M logs)
1. `rehydrated logs ingested sum` — Log Rehydration Ingestion ($0.10/GB)
1. `profiling hosts 99p` — Continuous Profiler ($12/host)
1. `database monitoring hosts 99p` — Database Monitoring ($70/host)
1. `npm hosts 99p` — Network Performance Monitoring ($8/host)

---

## Excluded Products (no unit price in startup pricing table)

These products appear in usage data but have no matching price and are **excluded from
cost totals.** Report their raw usage quantities with a "no price available" note.

* `siem_indexed` / `event_count_monthly_sum` — SIEM indexed events
* Flex Logs — various flex log dimensions
* `serverless_invocations` — Serverless invocations

---

## Bytes-to-GB Conversion

Log ingestion and forwarding dimensions store usage in bytes. Convert before applying
per-GB unit prices:

```
GB = bytes ÷ 1,073,741,824   (1 GB = 2^30 bytes)
```

The `logs forwarded sum` unit price in the pricing table is stored as `$2.5e-10/byte`,
which is equivalent to `$0.25/GB` after conversion.

---

## Org Scope Deduplication

The `org_scope` CTE uses `SELECT DISTINCT ID AS ORG_ID` to prevent double-counting
orgs that appear multiple times in `DIM_ORG` (e.g., due to datacenter variants or
historical records).

---

## Cost Model Compatibility

`BYOD_COST_GA_V2_US1_MICHELADA` is the GA V2 cost model table. It returns
`"unsupported"` for orgs on trial or free plans. Because most internal training orgs
use trial plans, this table is **not used for cost calculations.** It is queried only
to confirm plan type distribution for the org group.
