---
name: curriculum-performance-report
description: >-
  Generate a comprehensive curriculum performance report for a Datadog Learning Center
  curriculum area. Queries Snowflake for enrollment, completion, survey, RUM pageview, and
  demographic data; analyzes git history for content staleness; compiles a markdown report
  and interactive HTML dashboard. Use when asked to generate a course performance report,
  curriculum analytics, learning center metrics, course health report, or content staleness
  analysis for any curriculum area (APM, Logs, Infrastructure, Security, Monitors, RUM, etc.).
  Accepts a curriculum area label and category slug pattern as inputs.
---

# Curriculum Performance Report

Generates two output files for a named curriculum area:
* A detailed markdown report (`{area_lower}-course-performance-{YYYY-MM}.md`)
* An interactive HTML dashboard (`{area_lower}-course-performance-{YYYY-MM}.html`)

All data comes from Snowflake (`REPORTING.GENERAL`) via the Snowflake MCP server and from git history in the learning-center/courses repo.

## Inputs

Collect before starting Phase 1. Required fields must be confirmed; optional fields use defaults if not provided.

| Input | Required | Default | Example |
|---|---|---|---|
| `area_label` | Yes | -- | "APM", "Logs", "Infrastructure" |
| `category_slug_pattern` | Yes | -- | `%apm%`, `%log%`, `%infrastructure%` |
| `report_as_of_date` | No | today (YYYY-MM-DD) | "2026-03-10" |
| `time_range_months` | No | 6 | 3, 6, 12 |
| `exclude_slugs` | No | (none) | `'intro-to-apm', 'apm-draft'` |
| `bundle_ids` | No | (none -- skip LP sections) | `198361, 263268` |
| `courses_repo_path` | No | `/Users/alex.rosenkranz/workspace/learning-center/courses` | -- |
| `output_dir` | No | `/Users/alex.rosenkranz/workspace/alex/alex-admin/reports` | -- |

## Core CTE (Discovery Phase)

Run once during Phase 1 to discover courses:

```sql
WITH area_courses AS (
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
    AND c.SLUG NOT IN ({exclude_slugs_or_empty_string})
)
SELECT * FROM area_courses ORDER BY course_name
```

After user confirms the course list, **freeze** it as a VALUES CTE used in all subsequent queries:

```sql
WITH area_courses AS (
  SELECT * FROM VALUES
    ({course_id_1}, '{course_name_1}', '{course_slug_1}'),
    ({course_id_2}, '{course_name_2}', '{course_slug_2}')
    -- ... one row per approved course
  AS t(course_id, course_name, course_slug)
)
```

This prevents the LIKE pattern from overmatching in later queries.

## Small-Sample Thresholds

Apply these throughout report generation:
* **Survey per-course breakdown**: suppress if < 10 responses; show aggregate only
* **Company names in demographics**: suppress if < 5 enrollments from that company (privacy)
* **Free-text themes**: categorize into named themes if 20+ substantive responses; otherwise list notable quotes
* **Geographic**: suppress country rows with < 3 pageviews

When suppressing, note "< minimum threshold" in the report cell rather than leaving it blank.

## Key Tables

| Table | Purpose | Key Columns |
|---|---|---|
| `DIM_THINKIFIC_COURSE` | Course catalog | ID, NAME, SLUG |
| `DIM_THINKIFIC_PRODUCT` | Course-to-category bridge | PRODUCTABLE_ID, PRODUCTABLE_TYPE, ID |
| `DIM_THINKIFIC_CATEGORY` | Category by slug | PRODUCT_ID, SLUG |
| `DIM_THINKIFIC_ENROLLMENT` | Enrollment + completion events | ID, USER_ID, COURSE_ID, ENROLLMENT_TIMESTAMP, STATUS |
| `DEFAULT_LEARNING_CENTER_COURSE_SURVEY_RESPONSES` | Survey answers (4 questions) | ENROLLMENT_ID, RESPONSE1-4 |
| `FACT_RUM_SITE_PAGEVIEW_HISTORY` | Browser pageview events | PAGEVIEW_TIMESTAMP, PAGE_URLPATH, PAGE_URLHOST, SESSION_ID, DEVICE_TYPE, TIME_SPENT_ON_PAGE_SECONDS, SCROLL_DEPTH_PERCENTAGE, REFERRER_URL, GEO_COUNTRY |
| `DIM_THINKIFIC_USER` | Learner profile | ID, EMAIL_DOMAIN, COMPANY |
| `COURSES_BY_TCD` | Course-to-author mapping | COURSE_TITLE, PRIMARY_COURSE_DEVELOPER |

Key join patterns:
* **RUM to course**: `PAGE_URLPATH LIKE '/courses/take/' || ac.course_slug || '/%'` and `PAGE_URLHOST = 'learn.datadoghq.com'`
* **Survey to enrollment**: `DEFAULT_LEARNING_CENTER_COURSE_SURVEY_RESPONSES.ENROLLMENT_ID = DIM_THINKIFIC_ENROLLMENT.ID`
* **Learner demographics**: `DIM_THINKIFIC_ENROLLMENT.USER_ID = DIM_THINKIFIC_USER.ID`
* Note: `VISITOR_ID` in RUM is unpopulated -- use `SESSION_ID` for unique session counts

## Survey Questions (for interpreting RESPONSE1-4)
* RESPONSE1: "After taking this course, how much more proficient will you be using Datadog?" (proficiency)
* RESPONSE2: "How was the level of detail in this course?" (detail level)
* RESPONSE3: "Would you recommend this course to a colleague?" (recommendation)
* RESPONSE4: "Please provide additional feedback." (free text)

## Phased Workflow

Read `references/queries.md` before executing any query. All SQL templates are there.

---

### Phase 1: Discovery and Confirmation (PAUSE for user input)

1. Confirm `area_label` and `category_slug_pattern` with the user if not already provided.
1. Compute `start_date` and `end_date` from `report_as_of_date` and `time_range_months`.
1. Run the Core CTE (discovery version) to get the course list.
1. Run Q15 (full COURSES_BY_TCD scan) to get author mapping immediately.
1. For each discovered course slug, check for a matching directory in `courses_repo_path` (use `ls {courses_repo_path}` and match on slug or a close variant).
1. Present a table to the user: course name | author | repo dir (or "not found") | course ID.
1. Ask:
   * "Are these the right courses? Any to add or exclude?"
   * "Do you have learning path bundle IDs for this area?" (needed for LP sections)
1. After confirmation, build the frozen VALUES CTE from the approved course IDs.

---

### Phase 2: Enrollment, Completion, and Survey (no pause)

Run using the frozen `area_courses` CTE and `{start_date}`/`{end_date}`:
* **Q1**: Per-course enrollment & completion summary (Section 3)
* **Q2**: Monthly enrollment trend (Section 4)
* **Q3**: Monthly completion trend (Section 5)
* **Q4**: Learning path completion -- SKIP if no `bundle_ids` (Section 6)
* **Q5**: Average completion % for incomplete learners (Section 3 sub-table)
* **Q6**: Course survey aggregated responses -- RESPONSE1 (proficiency), RESPONSE3 (recommend), RESPONSE4 count (Section 7)
* **Q7**: Learning path survey -- SKIP if no `bundle_ids` (Section 8)

---

### Phase 3: RUM, Demographics, and Free-Text Feedback (no pause)

Run using the frozen CTE:
* **Q8**: Per-course RUM page engagement (Section 10)
* **Q9**: Device type breakdown (Section 11)
* **Q10**: Geographic distribution, top 5 per course (Section 12)
* **Q11**: Referrer analysis (Section 11)
* **Q12**: Monthly RUM pageview trend (Section 10)
* **Q13**: Email domain segmentation (Section 13)
* **Q14**: Top companies by course -- apply company suppression threshold (Section 13)
* **Q16**: Free-text RESPONSE4 where LENGTH(RESPONSE4) > 20 (Section 14)

---

### Phase 4: Git Staleness (no pause)

For each course with a resolved repo directory:
1. Run `git -C {courses_repo_path} log --reverse --format=%aI -- {repo_dir} | head -1` for creation date.
1. Run `git -C {courses_repo_path} log --format="%aI %s" -- {repo_dir} | head -20` for recent commits.
1. Identify the most recent **meaningful** commit -- exclude bulk infra commits matching any of these patterns in the subject:
   * `lab_config` or `changelog` (bulk config updates)
   * `splash page` or `TRAIN-2568` (site-wide splash page rework)
   * `alt` + `image` or `TRAIN-3773` (alt image formatting pass)
   * `partner timeout` or timeout-only changes
   * `Train-3160` or `TRAIN-2834` (known bulk landing page/lab_config passes)
1. Classify staleness from months since meaningful commit:
   * **Low**: 0-6 months
   * **Moderate**: 6-12 months
   * **High**: 12+ months
1. Categorize free-text from Q16 into themes (20+ responses) or notable quotes (< 20).

---

### Phase 5: Report Generation (PAUSE to confirm before writing files)

1. Present a brief summary of findings (5-10 bullets: top enrollment, completion rate, staleness count, survey highlights, key RUM insight).
1. Note any sections suppressed due to small sample sizes.
1. After user confirms, generate both output files:
   * **Markdown**: Use `references/report-template.md` as the section structure. Fill each section with data from Phases 2-4.
   * **HTML dashboard**: Use `assets/dashboard-template.html` as the base. Replace all `/* PLACEHOLDER */` data arrays with actual values. Replace `{area_label}` with the confirmed area name.
1. Write both files to `{output_dir}/`.

---

## Output Paths

* `{output_dir}/{area_label_lower}-course-performance-{report_as_of_date_YYYY-MM}.md`
* `{output_dir}/{area_label_lower}-course-performance-{report_as_of_date_YYYY-MM}.html`

## Mandatory Caveats (include in every report)

> **Data notes**: RUM `VISITOR_ID` is unpopulated in this dataset; unique visitor counts use `SESSION_ID` as a proxy. Survey results reflect only learners who completed the course and submitted a survey (self-selection bias). Learning path completion rates reflect full-path completions only; partial completions are counted as enrolled. Data for the final partial month is noted as partial. Org cost and pricing data are not included in this report.
