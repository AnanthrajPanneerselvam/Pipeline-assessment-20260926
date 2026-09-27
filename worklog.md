# Worklog

## 2026-09-26 — Project setup

* Reviewed the assessment requirements and identified the main components: BigQuery, dbt, attribution logic, streaming, dashboard, and documentation.
* Created the GitHub repository `Pipeline-assessment-20260926`.
* Created the dbt project and connected the local project with the repository.
* Decided to use the GA4 public ecommerce dataset in BigQuery.

## 2026-09-26 — BigQuery dataset exploration

* Explored the GA4 public BigQuery dataset.
* Identified the `ga4_obfuscated_sample_ecommerce` dataset and daily `events_*` tables.
* Reviewed event-level fields including event date, timestamp, user identifier, traffic source, and ecommerce information.
* Tested basic event counts directly in BigQuery before connecting the data to dbt.

## 2026-09-26 — dbt connection setup

* Configured the dbt project and BigQuery profile.
* Learned the difference between `dbt_project.yml` and `profiles.yml`.
* Verified that GitHub stores the transformation code while BigQuery stores and executes the data models.
* Started validating the dbt-to-BigQuery connection.

## 2026-09-27 — Source and staging design

* Designed the initial dbt DAG from the GA4 source to staging, intermediate models, attribution models, and dashboard tables.
* Planned a staging layer to standardize GA4 event fields before applying attribution logic.
* Reviewed how dbt `source()` and `ref()` will be used in the project.

## 2026-09-27 — Attribution logic

* Defined the initial approach for First-Click and Last-Click attribution.
* Identified user touchpoints and purchase events as the main inputs.
* Considered lookback-window, user identity, timestamp ordering, and tie-breaker assumptions.

## 2026-09-27 — Streaming design

* Designed a small streaming demonstration to insert sample GA4-style events into BigQuery.
* Planned to demonstrate the movement from incoming events to the transformed attribution/dashboard data.
* Documented deduplication and idempotency as considerations for repeated events.

## 2026-09-27 — Dashboard

* Built the initial dashboard structure for First-Click and Last-Click attribution.
* Added total attribution metrics, time-series analysis, channel/source breakdown, and streamed-event visibility.
* Checked that the dashboard can be refreshed against the latest available data.

## 2026-09-27 — Testing and documentation

* Added dbt tests for key fields and data quality assumptions.
* Reviewed the transformation DAG and verified model dependencies.
* Added assumptions, failure handling, monitoring considerations, and cost considerations to the project documentation.

## 2026-09-27 — Final validation

* Ran the complete pipeline from source through mart models.
* Verified attribution results against sample records manually.
* Reviewed the dashboard and streaming demonstration.
* Prepared the project for the final walkthrough and live SQL discussion.
