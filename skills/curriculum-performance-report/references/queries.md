# SQL Query Templates: Curriculum Performance Report

All queries run against `REPORTING.GENERAL` in Snowflake via `mcp__snowflake__run_snowflake_query`.

## Placeholders

Before running any query, substitute:
* `{area_courses_cte}` -- the frozen VALUES CTE built after Phase 1 confirmation (replaces the slug-based CTE)
* `{start_date}` -- e.g. `'2025-09-10'`
* `{end_date}` -- e.g. `'2026-03-10'`
* `{bundle_ids}` -- comma-separated, e.g. `198361, 263268` (only for Q4, Q7)

## Join Pattern Reference

```
RUM join:    PAGE_URLPATH LIKE '/courses/take/' || ac.course_slug || '/%'
             OR PAGE_URLPATH LIKE '/courses/' || ac.course_slug || '/%'
             AND PAGE_URLHOST = 'learn.datadoghq.com'

Survey join: DEFAULT_LEARNING_CENTER_COURSE_SURVEY_RESPONSES.COURSE_NAME = area_courses.course_name

User join:   DIM_THINKIFIC_ENROLLMENT.USER_ID = DIM_THINKIFIC_USER.ID

Enrollment:  DIM_THINKIFIC_ENROLLMENT.COURSE_ID = area_courses.course_id
```

---

## Discovery CTE (Phase 1 only -- replace with frozen VALUES CTE after confirmation)

```sql
SELECT DISTINCT
  c.ID AS course_id,
  c.NAME AS course_name,
  c.SLUG AS course_slug
FROM REPORTING.GENERAL.DIM_THINKIFIC_COURSE c
JOIN REPORTING.GENERAL.DIM_THINKIFIC_PRODUCT p
  ON p.PRODUCTABLE_ID = c.ID AND p.PRODUCTABLE_TYPE = 'Course'
JOIN REPORTING.GENERAL.DIM_THINKIFIC_CATEGORY cat
  ON cat.PRODUCT_ID = p.ID
WHERE LOWER(cat.SLUG) LIKE '{category_slug_pattern}'
ORDER BY c.NAME
```

## Frozen VALUES CTE (use for all Phase 2-4 queries)

After user confirms the course list, build this CTE from the confirmed course IDs and use it as `{area_courses_cte}` in every subsequent query:

```sql
WITH area_courses AS (
  SELECT * FROM VALUES
    (12345, 'Course Name One', 'course-slug-one'),
    (12346, 'Course Name Two', 'course-slug-two')
    -- add one row per confirmed course
  AS t(course_id, course_name, course_slug)
)
```

---

## Q1: Per-Course Enrollment & Completion Summary
*Used in: Section 3 (Enrollment & Completion by Course)*

```sql
{area_courses_cte}
SELECT
  ac.course_name,
  COUNT(e.ID) AS total_enrollments,
  SUM(CASE WHEN e.STATUS = 'completed' THEN 1 ELSE 0 END) AS completions,
  ROUND(100.0 * SUM(CASE WHEN e.STATUS = 'completed' THEN 1 ELSE 0 END) / NULLIF(COUNT(e.ID), 0), 1) AS completion_rate_pct,
  ROUND(AVG(e.PERCENTAGE_COMPLETED), 1) AS avg_pct_completed_all,
  ROUND(AVG(CASE WHEN e.STATUS != 'completed' THEN e.PERCENTAGE_COMPLETED END), 1) AS avg_pct_incomplete_learners
FROM area_courses ac
JOIN REPORTING.GENERAL.DIM_THINKIFIC_ENROLLMENT e ON e.COURSE_ID = ac.course_id
WHERE e.ENROLLMENT_TIMESTAMP >= {start_date}
  AND e.ENROLLMENT_TIMESTAMP < {end_date}
GROUP BY ac.course_name
ORDER BY total_enrollments DESC
```

---

## Q2: Monthly Enrollment Trend
*Used in: Section 4 (Monthly Trends)*

```sql
{area_courses_cte}
SELECT
  DATE_TRUNC('month', e.ENROLLMENT_TIMESTAMP) AS month,
  COUNT(e.ID) AS enrollments
FROM area_courses ac
JOIN REPORTING.GENERAL.DIM_THINKIFIC_ENROLLMENT e ON e.COURSE_ID = ac.course_id
WHERE e.ENROLLMENT_TIMESTAMP >= {start_date}
  AND e.ENROLLMENT_TIMESTAMP < {end_date}
GROUP BY 1
ORDER BY 1
```

---

## Q3: Monthly Completion Trend
*Used in: Section 5 (Monthly Trends)*

```sql
{area_courses_cte}
SELECT
  DATE_TRUNC('month', e.COMPLETED_AT_TIMESTAMP) AS month,
  COUNT(e.ID) AS completions
FROM area_courses ac
JOIN REPORTING.GENERAL.DIM_THINKIFIC_ENROLLMENT e ON e.COURSE_ID = ac.course_id
WHERE e.COMPLETED_AT_TIMESTAMP >= {start_date}
  AND e.COMPLETED_AT_TIMESTAMP < {end_date}
  AND e.STATUS = 'completed'
GROUP BY 1
ORDER BY 1
```

---

## Q4: Learning Path Completion Analysis
*SKIP if no bundle_ids provided. Used in: Section 6 (Learning Path Progress)*

```sql
WITH bundle_courses AS (
  SELECT
    b.ID AS bundle_id,
    b.NAME AS bundle_name,
    b.COURSE_ID,
    COUNT(*) OVER (PARTITION BY b.ID) AS total_courses_in_bundle
  FROM REPORTING.GENERAL.DIM_THINKIFIC_BUNDLE b
  WHERE b.ID IN ({bundle_ids})
),
user_course_completions AS (
  SELECT
    bc.bundle_id,
    bc.bundle_name,
    bc.total_courses_in_bundle,
    e.USER_ID,
    COUNT(DISTINCT CASE WHEN e.STATUS = 'completed' THEN e.COURSE_ID END) AS courses_completed
  FROM bundle_courses bc
  JOIN REPORTING.GENERAL.DIM_THINKIFIC_ENROLLMENT e ON e.COURSE_ID = bc.COURSE_ID
  WHERE e.ENROLLMENT_TIMESTAMP >= {start_date}
    AND e.ENROLLMENT_TIMESTAMP < {end_date}
  GROUP BY bc.bundle_id, bc.bundle_name, bc.total_courses_in_bundle, e.USER_ID
)
SELECT
  bundle_name,
  total_courses_in_bundle,
  COUNT(DISTINCT USER_ID) AS unique_learners,
  SUM(CASE WHEN courses_completed = total_courses_in_bundle THEN 1 ELSE 0 END) AS fully_completed_learners,
  ROUND(100.0 * SUM(CASE WHEN courses_completed = total_courses_in_bundle THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT USER_ID), 0), 1) AS full_completion_rate_pct,
  ROUND(AVG(courses_completed), 1) AS avg_courses_completed_per_learner
FROM user_course_completions
GROUP BY bundle_name, bundle_id, total_courses_in_bundle
```

---

## Q5: Average Completion % for Incomplete Learners
*Used in: Section 3 (sub-table)*

```sql
{area_courses_cte}
SELECT
  ac.course_name,
  COUNT(CASE WHEN e.STATUS != 'completed' AND e.PERCENTAGE_COMPLETED > 0 THEN 1 END) AS learners_started_not_finished,
  ROUND(AVG(CASE WHEN e.STATUS != 'completed' THEN e.PERCENTAGE_COMPLETED END), 1) AS avg_pct_incomplete_learners
FROM area_courses ac
JOIN REPORTING.GENERAL.DIM_THINKIFIC_ENROLLMENT e ON e.COURSE_ID = ac.course_id
WHERE e.ENROLLMENT_TIMESTAMP >= {start_date}
  AND e.ENROLLMENT_TIMESTAMP < {end_date}
GROUP BY ac.course_name
ORDER BY avg_pct_incomplete_learners DESC
```

---

## Q6: Course Survey Aggregated Responses
*Used in: Section 7 (Survey Feedback)*
*Note: Join is on COURSE_NAME string, not course_id. Suppress rows with < 10 total responses.*

```sql
{area_courses_cte}
SELECT
  s.COURSE_NAME,
  COUNT(*) AS total_survey_responses,
  SUM(CASE WHEN s.RESPONSE1 IN ('Significantly more proficient', 'Somewhat more proficient') THEN 1 ELSE 0 END) AS proficiency_sig_or_some,
  ROUND(100.0 * SUM(CASE WHEN s.RESPONSE1 IN ('Significantly more proficient', 'Somewhat more proficient') THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 1) AS proficiency_pct,
  SUM(CASE WHEN s.RESPONSE2 = 'The right amount of detail' THEN 1 ELSE 0 END) AS detail_right,
  SUM(CASE WHEN UPPER(s.RESPONSE3) = 'YES' THEN 1 ELSE 0 END) AS recommend_yes,
  ROUND(100.0 * SUM(CASE WHEN UPPER(s.RESPONSE3) = 'YES' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 1) AS recommend_rate_pct,
  SUM(CASE WHEN s.RESPONSE4 IS NOT NULL AND LENGTH(TRIM(s.RESPONSE4)) > 20 THEN 1 ELSE 0 END) AS substantive_feedback_count
FROM REPORTING.GENERAL.DEFAULT_LEARNING_CENTER_COURSE_SURVEY_RESPONSES s
JOIN area_courses ac ON ac.course_name = s.COURSE_NAME
WHERE s.DATE_COMPLETED >= {start_date}
  AND s.DATE_COMPLETED < {end_date}
GROUP BY s.COURSE_NAME
HAVING COUNT(*) >= 10
ORDER BY total_survey_responses DESC
```

---

## Q7: Learning Path Survey
*SKIP if no bundle_ids provided. Used in: Section 8.*
*Replace the LIKE patterns with terms matching the area (e.g. '%log%', '%apm%', '%infrastructure%').*

```sql
SELECT
  WHICH_PATH_DID_YOU_TAKE AS path_name,
  AFTER_FINISHING_HOW_PROFICIENT AS proficiency,
  COMPLETING_LEARNING_PATH_FELT AS difficulty,
  WHY_DID_TAKE_LEARNING_PATH AS motivation,
  COUNT(*) AS count
FROM REPORTING.GENERAL.LEARNING_PATH_SURVEY_RESPONSES
WHERE LOWER(WHICH_PATH_DID_YOU_TAKE) LIKE '%{area_label_lower}%'
  AND LEARNING_PATH_SURVEY_TIMESTAMP >= {start_date}
  AND LEARNING_PATH_SURVEY_TIMESTAMP < {end_date}
GROUP BY 1, 2, 3, 4
ORDER BY path_name, count DESC
```

---

## Q8: Per-Course RUM Page Engagement
*Used in: Section 10 (RUM Page Engagement)*
*Note: VISITOR_ID is unpopulated; use SESSION_ID for unique counts only.*

```sql
{area_courses_cte}
SELECT
  ac.course_name,
  COUNT(*) AS total_pageviews,
  COUNT(DISTINCT r.SESSION_ID) AS unique_sessions,
  ROUND(AVG(r.TIME_SPENT_ON_PAGE_SECONDS), 1) AS avg_time_on_page_secs,
  ROUND(AVG(r.SCROLL_DEPTH_PERCENTAGE), 1) AS avg_scroll_depth_pct
FROM area_courses ac
JOIN REPORTING.GENERAL.FACT_RUM_SITE_PAGEVIEW_HISTORY r
  ON (r.PAGE_URLPATH LIKE '/courses/take/' || ac.course_slug || '/%'
   OR r.PAGE_URLPATH LIKE '/courses/' || ac.course_slug || '/%'
   OR r.PAGE_URLPATH = '/courses/' || ac.course_slug || '/')
WHERE r.PAGE_URLHOST = 'learn.datadoghq.com'
  AND r.PAGEVIEW_TIMESTAMP >= {start_date}
  AND r.PAGEVIEW_TIMESTAMP < {end_date}
GROUP BY ac.course_name
ORDER BY total_pageviews DESC
```

---

## Q9: Device Type Breakdown
*Used in: Section 11 (Traffic Sources & Device Breakdown)*

```sql
{area_courses_cte}
SELECT
  ac.course_name,
  r.DEVICE_TYPE,
  COUNT(*) AS pageviews
FROM area_courses ac
JOIN REPORTING.GENERAL.FACT_RUM_SITE_PAGEVIEW_HISTORY r
  ON (r.PAGE_URLPATH LIKE '/courses/take/' || ac.course_slug || '/%'
   OR r.PAGE_URLPATH LIKE '/courses/' || ac.course_slug || '/%'
   OR r.PAGE_URLPATH = '/courses/' || ac.course_slug || '/')
WHERE r.PAGE_URLHOST = 'learn.datadoghq.com'
  AND r.PAGEVIEW_TIMESTAMP >= {start_date}
  AND r.PAGEVIEW_TIMESTAMP < {end_date}
GROUP BY ac.course_name, r.DEVICE_TYPE
ORDER BY ac.course_name, pageviews DESC
```

---

## Q10: Geographic Distribution (Top 5 per course)
*Used in: Section 12 (Geographic Distribution). Suppress countries with < 3 pageviews.*

```sql
{area_courses_cte},
ranked AS (
  SELECT
    ac.course_name,
    r.GEO_COUNTRY,
    COUNT(*) AS pageviews,
    ROW_NUMBER() OVER (PARTITION BY ac.course_name ORDER BY COUNT(*) DESC) AS rn
  FROM area_courses ac
  JOIN REPORTING.GENERAL.FACT_RUM_SITE_PAGEVIEW_HISTORY r
    ON (r.PAGE_URLPATH LIKE '/courses/take/' || ac.course_slug || '/%'
     OR r.PAGE_URLPATH LIKE '/courses/' || ac.course_slug || '/%'
     OR r.PAGE_URLPATH = '/courses/' || ac.course_slug || '/')
  WHERE r.PAGE_URLHOST = 'learn.datadoghq.com'
    AND r.PAGEVIEW_TIMESTAMP >= {start_date}
    AND r.PAGEVIEW_TIMESTAMP < {end_date}
    AND r.GEO_COUNTRY IS NOT NULL
  GROUP BY ac.course_name, r.GEO_COUNTRY
  HAVING COUNT(*) >= 3
)
SELECT course_name, GEO_COUNTRY, pageviews FROM ranked WHERE rn <= 5 ORDER BY course_name, rn
```

---

## Q11: Referrer Analysis
*Used in: Section 11 (Traffic Sources)*

```sql
{area_courses_cte}
SELECT
  ac.course_name,
  CASE
    WHEN r.REFERRER_URL IS NULL OR r.REFERRER_URL = '' THEN 'Direct / None'
    WHEN r.REFERRER_URL LIKE '%learn.datadoghq.com%' THEN 'Internal (learn.datadoghq.com)'
    WHEN r.REFERRER_URL LIKE '%docs.datadoghq.com%' THEN 'Datadog Docs'
    WHEN r.REFERRER_URL LIKE '%datadoghq.com%' THEN 'Datadog (other)'
    WHEN r.REFERRER_URL LIKE '%google.%' THEN 'Google Search'
    WHEN r.REFERRER_URL LIKE '%bing.%' THEN 'Bing Search'
    WHEN r.REFERRER_URL LIKE '%linkedin.%' THEN 'LinkedIn'
    ELSE 'Other External'
  END AS referrer_category,
  COUNT(*) AS pageviews
FROM area_courses ac
JOIN REPORTING.GENERAL.FACT_RUM_SITE_PAGEVIEW_HISTORY r
  ON (r.PAGE_URLPATH LIKE '/courses/take/' || ac.course_slug || '/%'
   OR r.PAGE_URLPATH LIKE '/courses/' || ac.course_slug || '/%'
   OR r.PAGE_URLPATH = '/courses/' || ac.course_slug || '/')
WHERE r.PAGE_URLHOST = 'learn.datadoghq.com'
  AND r.PAGEVIEW_TIMESTAMP >= {start_date}
  AND r.PAGEVIEW_TIMESTAMP < {end_date}
GROUP BY ac.course_name, referrer_category
ORDER BY ac.course_name, pageviews DESC
```

---

## Q12: Monthly RUM Pageview Trend
*Used in: Section 10 (monthly trend table)*

```sql
{area_courses_cte}
SELECT
  DATE_TRUNC('month', r.PAGEVIEW_TIMESTAMP) AS month,
  COUNT(*) AS total_pageviews,
  COUNT(DISTINCT r.SESSION_ID) AS unique_sessions,
  ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT r.SESSION_ID), 0), 1) AS pvs_per_session
FROM area_courses ac
JOIN REPORTING.GENERAL.FACT_RUM_SITE_PAGEVIEW_HISTORY r
  ON (r.PAGE_URLPATH LIKE '/courses/take/' || ac.course_slug || '/%'
   OR r.PAGE_URLPATH LIKE '/courses/' || ac.course_slug || '/%'
   OR r.PAGE_URLPATH = '/courses/' || ac.course_slug || '/')
WHERE r.PAGE_URLHOST = 'learn.datadoghq.com'
  AND r.PAGEVIEW_TIMESTAMP >= {start_date}
  AND r.PAGEVIEW_TIMESTAMP < {end_date}
GROUP BY 1
ORDER BY 1
```

---

## Q13: Email Domain Segmentation
*Used in: Section 13 (Learner Demographics)*

```sql
{area_courses_cte}
SELECT
  ac.course_name,
  CASE
    WHEN LOWER(u.EMAIL_DOMAIN) = 'datadoghq.com' THEN 'Internal (Datadog)'
    WHEN LOWER(u.EMAIL_DOMAIN) IN ('gmail.com','yahoo.com','hotmail.com','outlook.com','icloud.com','protonmail.com','aol.com','live.com','yahoo.co.jp','yahoo.co.uk') THEN 'Personal'
    WHEN u.EMAIL_DOMAIN IS NULL THEN 'Unknown'
    ELSE 'Corporate / Other'
  END AS domain_category,
  COUNT(*) AS enrollments
FROM area_courses ac
JOIN REPORTING.GENERAL.DIM_THINKIFIC_ENROLLMENT e ON e.COURSE_ID = ac.course_id
JOIN REPORTING.GENERAL.DIM_THINKIFIC_USER u ON u.ID = e.USER_ID
WHERE e.ENROLLMENT_TIMESTAMP >= {start_date}
  AND e.ENROLLMENT_TIMESTAMP < {end_date}
GROUP BY course_name, domain_category
ORDER BY course_name, enrollments DESC
```

---

## Q14: Top Companies by Course (Excluding Internal, Excluding < 5 enrollments)
*Used in: Section 13 (Learner Demographics). Privacy threshold: suppress companies with < 5 enrollments.*

```sql
{area_courses_cte},
company_ranked AS (
  SELECT
    ac.course_name,
    TRIM(u.COMPANY) AS company,
    COUNT(*) AS enrollments,
    ROW_NUMBER() OVER (PARTITION BY ac.course_name ORDER BY COUNT(*) DESC) AS rn
  FROM area_courses ac
  JOIN REPORTING.GENERAL.DIM_THINKIFIC_ENROLLMENT e ON e.COURSE_ID = ac.course_id
  JOIN REPORTING.GENERAL.DIM_THINKIFIC_USER u ON u.ID = e.USER_ID
  WHERE e.ENROLLMENT_TIMESTAMP >= {start_date}
    AND e.ENROLLMENT_TIMESTAMP < {end_date}
    AND LOWER(u.EMAIL_DOMAIN) != 'datadoghq.com'
    AND u.COMPANY IS NOT NULL AND TRIM(u.COMPANY) != ''
  GROUP BY ac.course_name, company
  HAVING COUNT(*) >= 5
)
SELECT course_name, company, enrollments FROM company_ranked WHERE rn <= 5 ORDER BY course_name, rn
```

---

## Q15: Course Author Mapping (Full Scan)
*Run in Phase 1 alongside Discovery. Returns all rows -- match against confirmed course list in-context.*
*Used in: Section 13 and Section 2 (Course Catalog)*

```sql
SELECT COURSE_TITLE, PRIMARY_COURSE_DEVELOPER
FROM REPORTING.GENERAL.COURSES_BY_TCD
ORDER BY COURSE_TITLE
```

After getting results, match each discovered course name against `COURSE_TITLE` using fuzzy in-context matching (lowercased comparison, allowing for minor title differences).

---

## Q16: Free-Text Feedback (Substantive Responses)
*Used in: Section 14 (Free-Text Feedback Themes)*
*Threshold: 20+ substantive responses = categorize into themes. < 20 = list notable quotes.*

```sql
{area_courses_cte}
SELECT
  s.COURSE_NAME,
  s.RESPONSE4,
  s.DATE_COMPLETED
FROM REPORTING.GENERAL.DEFAULT_LEARNING_CENTER_COURSE_SURVEY_RESPONSES s
JOIN area_courses ac ON ac.course_name = s.COURSE_NAME
WHERE s.DATE_COMPLETED >= {start_date}
  AND s.DATE_COMPLETED < {end_date}
  AND s.RESPONSE4 IS NOT NULL
  AND LENGTH(TRIM(s.RESPONSE4)) > 20
ORDER BY s.COURSE_NAME, s.DATE_COMPLETED DESC
```
