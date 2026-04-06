# Unit Price Reference

Static snapshot of unit prices from `REPORTING.GENERAL.DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION`.
Last queried: 2026-03-02.

> **When to re-query:** If a new product is being estimated or if more than ~6 months
> have passed since this snapshot, run the query below to refresh prices.
>
> ```sql
> SELECT PRODUCT_AGGREGATION, PRODUCT_NAME, PRICE_PER_UNIT, PRICING_NOTES
> FROM REPORTING.GENERAL.DIM_STARTUP_PRICING_BY_PRODUCT_AGGREGATION
> ORDER BY PRODUCT_AGGREGATION;
> ```

---

## Pricing Table

| PRODUCT_AGGREGATION | PRODUCT_NAME | PRICE_PER_UNIT | Unit | PRICING_NOTES |
|---|---|---|---|---|
| `infra hosts 99p` | Infrastructure Monitoring | $18.00 | per host/mo | 99p billing, use avg as proxy |
| `apm hosts 99p` | APM | $36.00 | per host/mo | 99p billing, use avg as proxy |
| `apm indexed spans sum` | APM - Indexed Spans (30-day) | $0.000003 | per span | $3.00 per 1M spans |
| `apm ingested spans sum` | APM - Ingested Spans | $0.10 | per GB | |
| `apm fargate tasks avg` | Fargate | $2.26 | per task | |
| `containers avg` | Container Monitoring | $1.35 | per container | monthly average |
| `custom metrics avg` | Custom Metrics | $0.05 | per metric | $5.00 per 100 metrics |
| `error tracking sum` | Error Tracking | $36.00 | tiered/mo | tiered pricing starting at $36 |
| `error events sum` | Error Tracking | $0.000036 | per event | $36.00 per 1M events |
| `logs forwarded sum` | Log Forwarding | $2.5e-10 | per byte | $0.25 per GB (convert bytes) |
| `logs ingested sum` | Log Ingestion | $0.10 | per GB | (convert bytes) |
| `live index logs indexed sum` | Log Management (15-day retention) | $0.00000255 | per log | $2.55 per 1M logs |
| `live index logs ingested sum` | Log Management - Ingestion | $0.10 | per GB | (convert bytes) |
| `rehydrated logs indexed sum` | Log Rehydration | $0.0000015 | per log | $1.50 per 1M logs |
| `rehydrated logs ingested sum` | Log Rehydration - Ingestion | $0.10 | per GB | (convert bytes) |
| `profiling hosts 99p` | Continuous Profiler | $12.00 | per host/mo | 99p billing, use avg as proxy |
| `database monitoring hosts 99p` | Database Monitoring | $70.00 | per host/mo | 99p billing, use avg as proxy |
| `ci visibility pipeline committers sum` | CI Visibility - Pipeline | $21.00 | per committer | |
| `ci visibility pipeline spans sum` | CI Visibility - Pipeline Spans | $0.000005 | per span | $5.00 per 1M spans |
| `ci visibility test committers sum` | CI Visibility - Test | $21.00 | per committer | |
| `ci visibility test spans sum` | CI Visibility - Test Spans | $0.000005 | per span | $5.00 per 1M spans |
| `cspm hosts 99p` | Cloud Security Management Pro | $12.00 | per host/mo | 99p billing, use avg as proxy |
| `cspm containers avg` | Cloud Security Management Pro - Containers | $1.80 | per container | monthly average |
| `csm enterprise hosts 99p` | Cloud Security Management Enterprise | $22.00 | per host/mo | 99p billing, use avg as proxy |
| `csm enterprise containers avg` | Cloud Security Management Enterprise - Containers | $1.80 | per container | monthly average |
| `cws hosts 99p` | Cloud Workload Security | $22.00 | per host/mo | 99p billing, use avg as proxy |
| `cws containers 99p` | Cloud Workload Security - Containers | $1.80 | per container | 99p billing |
| `network device monitoring sum` | Network Device Monitoring | $7.00 | per device | |
| `ndm devices 99p` | Network Device Monitoring | $7.00 | per device | 99p billing |
| `npm hosts 99p` | Network Performance Monitoring | $8.00 | per host/mo | 99p billing, use avg as proxy |

---

## Excluded Products (no unit price available)

The following billing dimensions appear in usage data but have no matching price in
the startup pricing table. Exclude them from cost totals; report raw usage quantities only.

| Dimension pattern | Product |
|---|---|
| `siem_indexed`, `event_count_monthly_sum` | SIEM |
| Various flex log dimensions | Flex Logs |
| `serverless_invocations` | Serverless |

---

## Normalization Notes

### Host-based dimensions (99p or avg)
`FACT_ORG_ALL_PRODUCT_USAGE_MONTHLY` stores the **sum of hourly snapshots** for the
month, not the 99th percentile. Divide by 744 to approximate average monthly hosts:

```
avg_hosts = PRODUCT_USAGE ÷ 744
estimated_cost = avg_hosts × unit_price
```

This is a lower bound; actual 99p billing will be higher.

### Bytes-based dimensions (logs)
Log ingestion/forwarding dimensions store usage in **bytes**. Convert to GB before
multiplying by per-GB prices:

```
gb = PRODUCT_USAGE ÷ 1073741824
estimated_cost = gb × unit_price
```

`logs forwarded sum` has a per-byte price ($2.5e-10); you can also apply directly to
raw bytes without conversion.

### Count-based dimensions (spans, events, logs indexed)
Apply unit price directly to `PRODUCT_USAGE` (no conversion needed):

```
estimated_cost = PRODUCT_USAGE × unit_price
```

### Container-based dimensions
`containers avg` stores the **average container count** over the month. Apply unit
price directly:

```
estimated_cost = PRODUCT_USAGE × unit_price
```
