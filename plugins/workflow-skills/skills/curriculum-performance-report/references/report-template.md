# {area_label} Learning Center Course Performance Report

**Period:** {start_date} to {end_date} ({time_range_months} months)
**Generated:** {report_as_of_date}
**Data source:** Snowflake `REPORTING.GENERAL`
**Scope:** {N} self-paced {area_label} courses categorized under the "{category_slug_pattern}" slug in Thinkific

---

## 1. Executive Summary

<!-- Populate after all data is collected. Fill KPIs from Q1, Q2, Q6, Q8, Q13, git analysis. -->

| Metric | Value |
|---|---|
| {area_label} courses in scope | **{N}** |
| Total enrollments ({time_range_months} months) | **{total_enrollments}** |
| Total completions | **{total_completions}** |
| Overall completion rate | **{completion_rate}%** |
| Peak enrollment month | **{peak_month} ({peak_enrollments})** |
| Highest-volume course | **{top_course_name} ({top_course_enrollments} enrollments)** |
| Highest completion rate | **{top_completion_course} ({top_completion_rate}%)** |
| Overall survey recommendation rate | **~{recommend_range}% across surveyed courses** |
| Total RUM pageviews ({area_label} courses, {time_range_months} months) | **~{total_rum_pvs}** across {N} courses |
| Learner audience (by email domain) | **~{corp_pct}% corporate, ~{personal_pct}% personal, ~{internal_pct}% Datadog internal** |
| Courses with High content staleness (12+ months) | **{high_staleness_count}** |

Key observations:

* {observation_1}
* {observation_2}
* {observation_3}
* {observation_4}
* {observation_5}

---

## 2. {area_label} Course Catalog

The following {N} courses were in scope for this report, identified via the `{category_slug_pattern}` category slug in Thinkific:

<!-- List from Phase 1 confirmed course set -->
1. {course_1}
1. {course_2}
...

### Course Repository Health

<!-- Populate from Phase 4 git analysis. Staleness: Low = 0-6 mo, Moderate = 6-12 mo, High = 12+ mo -->

| Course | Repo Directory | Added | Age | Last Meaningful Update | Mo. Since | Staleness |
|---|---|---|---|---|---:|---|
| {course} | {repo_dir} | {added_date} | {age} | {last_update_desc} | {months} | Low / Moderate / High |

---

## 3. Enrollment & Completion by Course

<!-- Populate from Q1 results -->

| Course | Enrollments | Completions | Completion Rate | Avg % Completed (Incomplete Learners) |
|---|---:|---:|---:|---:|
| {course} | {enrollments} | {completions} | {rate}% | {avg_pct}% |

---

## 4. Monthly Enrollment Trends

<!-- Populate from Q2 results. Note partial months. -->

| Month | Enrollments |
|---|---:|
| {month} | {enrollments} |

{Narrative: describe peak month, trend direction, notable anomalies.}

---

## 5. Monthly Completion Trends

<!-- Populate from Q3 results. -->

| Month | Completions |
|---|---:|
| {month} | {completions} |

{Narrative: describe completion trend relative to enrollment trend, lag observations.}

---

## 6. Learning Path Progress

<!-- CONDITIONAL: Include only if bundle_ids were provided. Otherwise note "No learning path bundle IDs provided for this report." -->
<!-- Populate from Q4 results. -->

| Learning Path | Total Courses | Unique Learners | Fully Completed | Full Completion Rate | Avg Courses Completed |
|---|---:|---:|---:|---:|---:|
| {bundle_name} | {N} | {learners} | {full_completions} | {rate}% | {avg} |

{Narrative: observations on LP drop-off, typical completion depth.}

---

## 7. Course Survey Feedback

<!-- Populate from Q6 results. Suppress rows with < 10 responses. Note suppressed courses. -->

| Course | Responses | Would Recommend % | Proficiency Gain % | Substantive Free-Text Responses |
|---|---:|---:|---:|---:|
| {course} | {count} | {rec_pct}% | {prof_pct}% | {free_text_count} |

Courses with < 10 survey responses: {list or "none"}

---

## 8. Learning Path Survey Feedback

<!-- CONDITIONAL: Include only if bundle_ids were provided and LP survey data exists. -->
<!-- Populate from Q7 results. Note if sample is too small (< 10 responses). -->

| Path | Proficiency | Difficulty | Motivation | Count |
|---|---|---|---|---:|
| {path} | {proficiency} | {difficulty} | {motivation} | {count} |

---

## 9. Appendix: Core SQL Queries

<!-- Insert the frozen area_courses VALUES CTE and Q1-Q7 queries with actual values substituted. -->

### Course Identification CTE (frozen)

```sql
WITH area_courses AS (
  SELECT * FROM VALUES
    -- ... actual confirmed course IDs/names/slugs
  AS t(course_id, course_name, course_slug)
)
```

### Q1: Per-Course Enrollment & Completion Summary
...

*(Continue with Q2-Q7 templates from references/queries.md, substituted with actual dates.)*

---

## 10. RUM Page Engagement

<!-- Populate from Q8 and Q12 results. Note: VISITOR_ID unpopulated, using SESSION_ID. -->

### Per-Course Page Engagement

| Course | Total Pageviews | Unique Sessions | Avg Time on Page (s) | Avg Scroll Depth |
|---|---:|---:|---:|---:|
| {course} | {pvs} | {sessions} | {time}s | {scroll}% |

### Monthly Pageview Trend

| Month | Total Pageviews | Unique Sessions | PVs per Session |
|---|---:|---:|---:|
| {month} | {pvs} | {sessions} | {ratio} |

{Narrative: peak month, engagement anomalies, time-on-page outliers.}

---

## 11. Traffic Sources & Device Breakdown

### Traffic Sources (Referrer Categories)

<!-- Populate from Q11 results. Summarize by category across courses. -->

| Referrer Category | Notes |
|---|---|
| Internal (learn.datadoghq.com) | {pct_range}% of PVs across all courses |
| Direct / None | {pct_range}% |
| Google Search | {pct_range}% |
| Datadog Docs | Notable for: {list notable courses} |
| Other External | {notes} |

### Device Type Breakdown

<!-- Populate from Q9 results. Flag any course with > 5% mobile as notable. -->

| Course | Desktop | Mobile | Tablet |
|---|---:|---:|---:|
| {course} | {desktop_pvs} ({desktop_pct}%) | {mobile_pvs} ({mobile_pct}%) | {tablet_pvs} ({tablet_pct}%) |

---

## 12. Geographic Distribution

### Top 5 Countries by Pageviews (per course)

<!-- Populate from Q10 results. -->

| Course | #1 | #2 | #3 | #4 | #5 |
|---|---|---|---|---|---|
| {course} | {country} ({pvs}) | ... | ... | ... | ... |

Geographic highlights:
* {observation about dominant markets}
* {observation about any unusual concentrations}

---

## 13. Learner Demographics

### Email Domain Segmentation

<!-- Populate from Q13 results. -->

| Course | Corporate / Other | Personal | Internal (Datadog) | Total Matched |
|---|---:|---:|---:|---:|
| {course} | {N} ({pct}%) | {N} ({pct}%) | {N} ({pct}%) | {total} |

### Notable Companies (External Learners)

<!-- Populate from Q14 results. Suppress companies with < 5 enrollments. -->
<!-- Note if company data is sparse (many learners don't fill this field). -->

* {company}: {N} enrollments across {courses}

### Course Author Mapping

<!-- Populate from Q15 results (fuzzy-matched in-context against the confirmed course list). -->

| Author | Courses Owned |
|---|---|
| {author} | {course_list} |
| Not in COURSES_BY_TCD | {course_list} |

---

## 14. Free-Text Feedback Themes

<!-- Populate from Q16 results. -->
<!-- For courses with >= 20 substantive responses: group into named themes with representative quotes. -->
<!-- For courses with < 20 responses: list notable quotes only. -->
<!-- Common themes to watch for: lab reliability, UI staleness, positive feedback, video requests, content depth, language/accessibility. -->

### {Top Course Name} ({N} substantive responses)

**Theme 1: {Theme Name} (~{pct}% of responses)**
{Description of theme pattern.}
> "Quote 1"
> "Quote 2"

**Theme 2: ...**

---

### Other Courses: Notable Feedback

**{Course Name} ({N} substantive responses):**
* {Notable feedback point 1}
* {Notable feedback point 2}
> "Notable quote"

---

## 15. Notes: RUM Metrics via pup CLI

The `pup` CLI (`/Users/alex.rosenkranz/go/bin/pup`) is authenticated via OAuth and available for management-plane operations. However, it does not support query-plane event aggregation. All historical RUM data in this report was sourced from Snowflake (`FACT_RUM_SITE_PAGEVIEW_HISTORY`).

Available pup rum subcommands for future reference: `sessions list`, `heatmaps`, `retention-filters list`, `metrics list`. Event-level analytics (error rates, load times) require the Datadog Metrics API, not pup.

---

## 16. Appendix: Additional SQL Queries

*(Insert Q8-Q16 templates from references/queries.md with actual dates substituted.)*

---

> **Data notes**: RUM `VISITOR_ID` is unpopulated in this dataset; unique visitor counts use `SESSION_ID` as a proxy. Survey results reflect only learners who completed the course and submitted a survey (self-selection bias). Learning path completion rates reflect full-path completions only; partial completions are counted as enrolled. Data for the final partial month is noted as partial.
