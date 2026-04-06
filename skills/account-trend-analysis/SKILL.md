---
name: account-trend-analysis
description: Analyze account usage state and trends from Snowflake data. Use when analyzing account usage, investigating trends by product, reviewing account activity, examining organization metrics, or providing account insights. Accepts account name or organization identifier as input. (project, gitignored)
---

# Account Trend Analysis

This skill analyzes account state and usage trends by querying Snowflake data sources. It identifies usage patterns by product over recent months and provides factual, evidence-based insights.

## Core Principles

**CRITICAL**: This skill emphasizes factual analysis only. NEVER make up data, infer causation without evidence, or speculate about unclear trends. When reasons are unclear, explicitly state what is known and what remains uncertain.

---

## Quick Start

When the user requests account analysis:
1. **Identify**: Account name/org_id + product(s) + time range (default: 6 months)
2. **Get revenue trends**: Use mapping table join (see below)
3. **Compare products**: Determine if trend is product-specific or account-wide
4. **Add context**: Pull Salesforce data (health, risk flags, opportunities)
5. **Drill down**: For anomalies, check billing dimensions
6. **Report**: Structured findings with recommendations

---

## Core Data Tables

### Primary Tables (Use These)

1. **`REPORTING.BILLING.FACT_USAGE_REVENUE_BY_PRODUCT_MONTHLY`**
   - Main revenue/usage data source
   - **MUST join with DIM_PRODUCT_CATEGORY_MAPPING for accurate filtering**
   - Key columns: `ORG_ID`, `REVENUE_MONTH`, `TOTAL_REVENUE`, `ON_DEMAND_REVENUE`, `COMMITTED_REVENUE`, `BILLING_DIMENSION_ATTRIBUTED`

2. **`REPORTING.GENERAL.DIM_PRODUCT_CATEGORY_MAPPING`** ⭐ **CRITICAL**
   - Maps billing dimensions to correct product categories
   - Key columns: `BILLING_DIMENSION`, `PRODUCT_CATEGORY_MBR`, `PRODUCT_FAMILY_MBR`
   - **Join key**: `BILLING_DIMENSION = fact_table.BILLING_DIMENSION_ATTRIBUTED`

3. **`REPORTING.GENERAL.DIM_SALESFORCE_ACCOUNT`**
   - Account health, risk, and business context
   - Key columns: `ORG_ID`, `NAME`, `ACCOUNT_HEALTH_STATUS`, `CHURN_RISK_LIKELIHOOD`, `CHURN_RISK_REASON`, `CUSTOMER_TIER`

4. **`REPORTING.SALES.DIM_SALESFORCE_OPPORTUNITY`**
   - Opportunity pipeline and risk flags
   - Key columns: `ORG_ID`, `SALESFORCE_ACCOUNT_ID`, `OPPORTUNITY_NAME`, `RISK_RED_FLAGS`, `PRIMARY_COMPETITOR`, `CLOSED_LOST_REASON`

### Product Category Values (for filtering)
- `'application performance monitoring'` - APM
- `'infrastructure monitoring'` - Infrastructure
- `'log management'` - Logs
- `'real user monitoring'` - RUM
- `'network monitoring'` - Network
- `'database monitoring'` - Database Monitoring
- `'serverless'` - Serverless

---

## ⚠️ CRITICAL: Product Category Filtering Pattern

**ALWAYS use this join pattern for accurate product categorization:**

```sql
FROM REPORTING.BILLING.FACT_USAGE_REVENUE_BY_PRODUCT_MONTHLY f
JOIN REPORTING.GENERAL.DIM_PRODUCT_CATEGORY_MAPPING m
  ON f.BILLING_DIMENSION_ATTRIBUTED = m.BILLING_DIMENSION
WHERE m.PRODUCT_CATEGORY_MBR = 'application performance monitoring'  -- or other product
```

**❌ NEVER do this:**
```sql
WHERE PRODUCT_CATEGORY = 'apm'  -- WRONG - incomplete/inaccurate data
```

**Why this matters:**
- The mapping table is the **source of truth** for product categorization
- Billing dimensions can map to multiple products or change over time
- Using the direct `PRODUCT_CATEGORY` field gives incomplete results
- The join ensures you get ALL revenue that should be attributed to the product

---

## Analysis Workflow

### Phase 1: Quick Context (5 queries, ~5 minutes)

**Goal:** Get high-level trends and identify which orgs need deep dives

1. **Validate org IDs and get account names**
```sql
SELECT ORG_ID, NAME, ACCOUNT_HEALTH_STATUS, CHURN_RISK_LIKELIHOOD
FROM REPORTING.GENERAL.DIM_SALESFORCE_ACCOUNT
WHERE ORG_ID IN (list_of_orgs);
```

2. **Get revenue trends with MoM % (6 months)**
```sql
WITH monthly_revenue AS (
  SELECT
    f.ORG_ID,
    f.REVENUE_MONTH,
    SUM(f.TOTAL_REVENUE) as revenue
  FROM REPORTING.BILLING.FACT_USAGE_REVENUE_BY_PRODUCT_MONTHLY f
  JOIN REPORTING.GENERAL.DIM_PRODUCT_CATEGORY_MAPPING m
    ON f.BILLING_DIMENSION_ATTRIBUTED = m.BILLING_DIMENSION
  WHERE m.PRODUCT_CATEGORY_MBR = 'application performance monitoring'  -- adjust as needed
    AND f.ORG_ID IN (list_of_orgs)
    AND f.REVENUE_MONTH >= DATEADD(month, -6, CURRENT_DATE())
  GROUP BY f.ORG_ID, f.REVENUE_MONTH
),
with_lag AS (
  SELECT
    ORG_ID,
    REVENUE_MONTH,
    revenue,
    LAG(revenue) OVER (PARTITION BY ORG_ID ORDER BY REVENUE_MONTH) as prev_revenue
  FROM monthly_revenue
)
SELECT
  ORG_ID,
  REVENUE_MONTH,
  ROUND(revenue, 2) as current_revenue,
  ROUND((revenue - prev_revenue) / NULLIF(prev_revenue, 0) * 100, 1) as mom_change_pct
FROM with_lag
ORDER BY ORG_ID, REVENUE_MONTH DESC;
```

3. **Cross-product comparison (Are trends product-specific?)**
```sql
SELECT
  f.ORG_ID,
  m.PRODUCT_CATEGORY_MBR,
  f.REVENUE_MONTH,
  SUM(f.TOTAL_REVENUE) as revenue
FROM REPORTING.BILLING.FACT_USAGE_REVENUE_BY_PRODUCT_MONTHLY f
JOIN REPORTING.GENERAL.DIM_PRODUCT_CATEGORY_MAPPING m
  ON f.BILLING_DIMENSION_ATTRIBUTED = m.BILLING_DIMENSION
WHERE f.ORG_ID IN (list_of_orgs)
  AND f.REVENUE_MONTH >= DATEADD(month, -6, CURRENT_DATE())
  AND m.PRODUCT_CATEGORY_MBR IN (
    'application performance monitoring',
    'infrastructure monitoring',
    'log management',
    'real user monitoring',
    'network monitoring'
  )
GROUP BY f.ORG_ID, m.PRODUCT_CATEGORY_MBR, f.REVENUE_MONTH
ORDER BY f.ORG_ID, m.PRODUCT_CATEGORY_MBR, f.REVENUE_MONTH DESC;
```
**Limit to 5-7 products to avoid token limits**

4. **Get Salesforce business context**
```sql
SELECT
  sa.NAME as account_name,
  sa.ORG_ID,
  sa.ACCOUNT_HEALTH_STATUS,
  sa.CHURN_RISK_LIKELIHOOD,
  sa.CHURN_RISK_REASON,
  sa.CUSTOMER_TIER,
  so.OPPORTUNITY_NAME,
  so.STAGE_CURRENT,
  so.RISK_RED_FLAGS,
  so.PRIMARY_COMPETITOR,
  so.CLOSE_DATE
FROM REPORTING.GENERAL.DIM_SALESFORCE_ACCOUNT sa
LEFT JOIN REPORTING.SALES.DIM_SALESFORCE_OPPORTUNITY so
  ON sa.ID = so.SALESFORCE_ACCOUNT_ID
WHERE sa.ORG_ID IN (list_of_orgs)
  AND (so.IS_OPEN = TRUE OR so.CLOSE_DATE >= DATEADD(month, -6, CURRENT_DATE()))
ORDER BY sa.ORG_ID, so.CLOSE_DATE DESC
LIMIT 50;
```

5. **Spot-check: Filter out orgs with no data**

---

### Phase 2: Deep Dive (Only for Interesting Patterns)

**Goal:** Understand "what changed" within the product

For orgs with:
- MoM changes > ±20%
- Sudden spikes or drops
- Red/Yellow health status

6. **Billing dimension breakdown**
```sql
SELECT
  f.REVENUE_MONTH,
  f.BILLING_DIMENSION_ATTRIBUTED,
  ROUND(SUM(f.TOTAL_REVENUE), 2) as revenue,
  ROUND(SUM(f.TOTAL_REVENUE) - LAG(SUM(f.TOTAL_REVENUE)) OVER (
    PARTITION BY f.BILLING_DIMENSION_ATTRIBUTED
    ORDER BY f.REVENUE_MONTH
  ), 2) as mom_change_abs,
  ROUND(((SUM(f.TOTAL_REVENUE) - LAG(SUM(f.TOTAL_REVENUE)) OVER (
    PARTITION BY f.BILLING_DIMENSION_ATTRIBUTED
    ORDER BY f.REVENUE_MONTH
  )) / NULLIF(LAG(SUM(f.TOTAL_REVENUE)) OVER (
    PARTITION BY f.BILLING_DIMENSION_ATTRIBUTED
    ORDER BY f.REVENUE_MONTH
  ), 0) * 100), 1) as mom_change_pct
FROM REPORTING.BILLING.FACT_USAGE_REVENUE_BY_PRODUCT_MONTHLY f
JOIN REPORTING.GENERAL.DIM_PRODUCT_CATEGORY_MAPPING m
  ON f.BILLING_DIMENSION_ATTRIBUTED = m.BILLING_DIMENSION
WHERE f.ORG_ID = specific_org
  AND m.PRODUCT_CATEGORY_MBR = 'application performance monitoring'
  AND f.REVENUE_MONTH >= DATEADD(month, -6, CURRENT_DATE())
GROUP BY f.REVENUE_MONTH, f.BILLING_DIMENSION_ATTRIBUTED
ORDER BY f.REVENUE_MONTH DESC, revenue DESC;
```

**This reveals:**
- Which component changed (hosts, spans, Fargate, etc.)
- Whether it's optimization vs. actual usage change

---

### Phase 3: Synthesis & Reporting

7. **Use decision tree** (see below) to categorize the trend
8. **Write structured report** with recommendations

---

## Decision Trees

### Is the trend product-specific or account-wide?

```
Product revenue declining?
├─ YES → Are other products also declining?
│  ├─ YES → **Account-wide issue** (NEGATIVE)
│  │        Actions:
│  │        - Check Salesforce RISK_RED_FLAGS for root cause
│  │        - Look for: budget pressure, competitor threat, churn risk
│  │        - Assess if intervention needed (CSM, product team)
│  │
│  └─ NO → **Product-specific issue**
│     └─ Check billing dimensions breakdown
│        ├─ One dimension dropped sharply?
│        │  → Likely optimization (often POSITIVE)
│        │  → Example: ingested_spans dropped 70% while apm_host grew
│        │
│        └─ All dimensions declining?
│           → Coverage reduction (NEGATIVE)
│           → Teams may be migrating away from product
│
└─ NO → Product stable or growing
   └─ Check for spike-then-drop pattern
      ├─ Large spike one month, then 30-70% drop next month?
      │  → Migration with optimization (POSITIVE)
      │  → Example: Enable full tracing, then implement sampling
      │
      └─ Steady growth?
         → Healthy expansion (POSITIVE)
```

---

## Common Patterns & Interpretation

### Pattern 1: Spike → 30-70% Drop (Optimization Pattern)

**What it looks like:**
- Month 1: $200K
- Month 2: $450K (+125%)
- Month 3: $300K (-33%)

**Likely cause:** Optimization after migration
- Teams migrate with verbose settings (full tracing, 100% sampling)
- See costs, implement optimization (sampling, filtering)
- Core coverage (hosts, containers) continues to grow

**How to validate:**
- Check billing dimensions
- If `ingested_spans` or similar volume metric dropped sharply while `apm_host`/`infra_host` grew → **CONFIRMED**

**Assessment:** ✅ POSITIVE - Sophisticated cost management, long-term commitment

**Example:** Itau Unibanco Aug→Sep 2025
- ingested_spans: $194K → $56K (-71%)
- apm_host: $216K → $226K (+5%)
- **Result:** Optimization, not reduction

---

### Pattern 2: Steady Decline Across All Products (Account Health Issue)

**What it looks like:**
- APM: -15% → -20% → -25%
- Infrastructure: -12% → -18% → -22%
- Logs: -10% → -15% → -20%
- All products trending down together

**Likely causes:**
- Budget pressure / cost cutting
- Competitor threat (switching to alternative)
- Churn risk / dissatisfaction
- Migration away from platform

**How to validate:**
- Check Salesforce `RISK_RED_FLAGS` and `CHURN_RISK_REASON`
- Look for opportunity notes mentioning competitors
- Check `ACCOUNT_HEALTH_STATUS` (likely Red or Yellow)

**Assessment:** 🔴 NEGATIVE - Requires immediate attention

**Example:** UKG
- All major products declining 15-50%
- Salesforce flag: "Entire account at risk, Grafana competition"
- Account health: Red

---

### Pattern 3: One Product Volatile, Others Stable (Project-Based Usage)

**What it looks like:**
- Target product: $20K → $100K → $30K → $25K → $105K
- Other products: Stable within ±10%

**Likely causes:**
- Project-based or seasonal usage
- A/B testing or experimentation
- Organizational changes (team restructuring)
- M&A uncertainty

**How to validate:**
- Check for merger/acquisition activity
- Look for leadership changes or reorgs
- Review recent opportunity notes for context

**Assessment:** ⚠️ NEUTRAL - Monitor but may not be concerning

**Example:** Pluto TV
- APM: Extreme volatility ($16K → $106K → $39K)
- Other products: Stable
- Context: Paramount merger creating uncertainty

---

## Key Billing Dimensions by Product

### APM (Application Performance Monitoring)
- **`apm_host`** - Core APM coverage (if this drops, coverage is down) 🔴
- **`apm_fargate`** - Fargate-specific APM
- **`ingested_spans`** - Trace volume (drops here often = optimization) ✅
- **`apm_trace_search`** - Trace analysis usage
- **`data_stream_monitoring`** - Data stream monitoring

**Key insight:** If `apm_host` grows but `ingested_spans` drops → Optimization ✅

### Infrastructure
- **`infra_host`** - Host count (core metric) 🔴
- **`infra_container`** - Container monitoring
- **`infra_aas`** - Infrastructure as a service

### Logs
- **`logs_indexed`** - Indexed log volume
- **`logs_ingested`** - Total log ingestion
- **Flex logs dimensions** - Various flex log SKUs

### RUM (Real User Monitoring)
- **`rum_sessions`** - Session count
- **`rum_lite`** - RUM Lite sessions

---

## Do's and Don'ts

### ✅ Always Do:
- **Join DIM_PRODUCT_CATEGORY_MAPPING** using `BILLING_DIMENSION_ATTRIBUTED`
- **Compare across products** to determine if trend is product-specific
- **Get Salesforce context** (health, risk flags, opportunities)
- **Check billing dimensions** for anomalies to understand "what changed"
- **Limit queries to 6-12 months** to avoid token limits
- **Filter noise** with `WHERE revenue > 1000`
- **Use exact numbers** from queries in reports
- **State uncertainty** when data is unclear

### ❌ Never Do:
- **Use PRODUCT_CATEGORY directly** - always join mapping table
- **Assume optimization = reduction** - check billing dimensions first!
- **Skip cross-product comparison** - critical to understanding scope
- **Query all-time data** - token limits will exceed 25K
- **Ignore Salesforce context** - explains the "why" behind trends
- **Make up reasons** - be factual, state when unclear
- **Forget NULLIF** when calculating percentages (prevents divide-by-zero)

---

## Query Optimization Tips

1. **Token Limit Management:**
   - Limit to 6 months for detailed analysis (12 max)
   - Filter to 5-7 top products for cross-product comparison
   - Use `WHERE revenue > 1000` to filter noise
   - Use `LIMIT` aggressively in exploratory queries

2. **Join Optimization:**
   - Always use the mapping table join (it's fast)
   - Filter on `REVENUE_MONTH` early (reduces rows scanned)
   - Use `ROUND()` to reduce precision (fewer tokens in output)

3. **Aggregation:**
   - Monthly aggregation is usually sufficient for trends
   - Use window functions (`LAG`, `LEAD`) for MoM calculations
   - Avoid daily/hourly unless specifically needed

---

## Report Structure

### 1. Executive Summary
- **Key Finding:** Product-specific or account-wide trend?
- **Magnitude:** Revenue changes, MoM percentages
- **Risk Assessment:** Green/Yellow/Red based on health + trends
- **Top Movers:** Biggest expansions/contractions

### 2. Detailed Analysis Per Org
For each org:
- **Account Overview:** Name, org_id, segment, customer tier
- **Revenue Trends:** Last 6 months with MoM %
- **Cross-Product Comparison:** Is trend isolated or account-wide?
- **Business Context:** Salesforce health, risk flags, opportunities
- **Billing Dimension Breakdown:** (For anomalies only) What changed?
- **Pattern Classification:** Which pattern does this match?

### 3. Observations & Recommendations
- **Clear facts** based on data
- **Patterns** identified with supporting numbers
- **Recommendations** by risk level:
  - 🔴 High Risk: Immediate CSM/sales intervention needed
  - 🟡 Medium Risk: Monitor closely, schedule check-in
  - 🟢 Low Risk: Healthy, no action needed
- **Areas of uncertainty** or need for follow-up

**IMPORTANT:**
- Use exact numbers from queries
- Cite specific date ranges
- When trends are unclear, state: "The data shows [specific observations], but the underlying reason is unclear from available metrics."
- Avoid phrases like "likely due to", "probably because", "suggests that" unless you have supporting data

---

## Usage Examples

### Example 1: Analyze APM trends for specific orgs
```
Analyze APM trends for orgs: 39037, 1561702, 1000113427, 604170, 700722
Product focus: application performance monitoring
Time range: Last 6 months
```

**Expected flow:**
1. Validate org_ids, get account names
2. Get APM revenue trends with MoM %
3. Compare APM vs other products (Infrastructure, Logs, RUM)
4. Pull Salesforce context
5. For orgs with >±20% changes, check billing dimensions
6. Classify patterns, provide recommendations

---

### Example 2: Account health check (all products)
```
Analyze account health for org: 700722
Compare: APM, Infrastructure, Logs, RUM, Serverless, Network
Time range: Last 12 months
```

**Expected flow:**
1. Get revenue for all major products
2. Calculate MoM trends for each
3. Identify cross-product patterns
4. Pull Salesforce health and risk data
5. Assess overall account health
6. Provide strategic recommendations

---

### Example 3: Find top movers
```
Find top 3 expansions and contractions for:
Product: application performance monitoring
Period: August 2025 vs September 2025
```

**Expected flow:**
1. Query all orgs with APM revenue in Aug & Sep
2. Calculate absolute change
3. Get top 3 up, top 3 down
4. For each, get account name + health status
5. Provide context on why each moved

---

## Troubleshooting

### "No data returned"
- ✅ Verify org_id exists in DIM_SALESFORCE_ACCOUNT
- ✅ Check REVENUE_MONTH range has data
- ✅ Confirm PRODUCT_CATEGORY_MBR value is correct (check distinct values)
- ✅ Ensure mapping table join is present

### "Token limit exceeded"
- ✅ Reduce time range (6 months instead of 12)
- ✅ Limit products in cross-product comparison (5-7 max)
- ✅ Add `WHERE revenue > 1000` to filter noise
- ✅ Use `LIMIT` to cap result size

### "Unexpected revenue values"
- ✅ Verify using mapping table join (not direct PRODUCT_CATEGORY)
- ✅ Check if filtering on BILLING_DIMENSION_ATTRIBUTED correctly
- ✅ Confirm PRODUCT_CATEGORY_MBR spelling (case-sensitive)

### "Trends don't make sense"
- ✅ Compare with other products (is it product-specific or account-wide?)
- ✅ Check billing dimensions (optimization vs. reduction)
- ✅ Pull Salesforce context (business reasons)
- ✅ Validate time range (ensure not comparing incomplete months)

---

## Best Practices Reminder

### Data Quality
- Always validate that the account identifier exists before querying usage
- Check for null values or data gaps in the time series
- Note any periods with missing data in your report

### Factual Reporting
- ✅ "Usage decreased 23% from June to July (from $45K to $35K)"
- ❌ "Usage decreased probably due to summer vacation"
- ✅ "APM declined 26% while Infrastructure grew 18%, suggesting APM-specific optimization"
- ❌ "APM declined because customers don't see value"

### Handling Uncertainty
When data is insufficient or unclear:
- State exactly what data you have
- Identify what data would be needed to clarify
- Suggest follow-up queries or investigations

**Example:** "APM revenue dropped 40% in September (from $200K to $120K). Billing dimension data shows ingested_spans dropped 70% while apm_host grew 5%, indicating this is likely span sampling optimization rather than coverage reduction. However, without customer interviews, we cannot confirm the specific optimization techniques used."

---

## Remember

**The goal is not to guess why trends exist, but to:**
1. ✅ Accurately measure what happened (facts, numbers, dates)
2. ✅ Classify the pattern (which known pattern does this match?)
3. ✅ Provide business context (Salesforce data)
4. ✅ Recommend actions based on risk level
5. ✅ State clearly when reasons are unclear

**When in doubt:** Report the facts, classify the pattern, state uncertainty, and recommend follow-up.
