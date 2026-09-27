# GA4 Attribution Pipeline

## 1. Project Overview

This project builds a simple GA4 attribution pipeline using BigQuery and dbt.

The main goal is to calculate **First Click** and **Last Click** attribution for purchases from the GA4 public ecommerce dataset.

The pipeline takes GA4 event data, cleans and prepares it using dbt, identifies user sessions and marketing touchpoints, and then connects those touchpoints to purchases using a 14-day lookback window.

The final data is prepared in a dashboard-friendly format so that First Click and Last Click attribution can be compared by revenue, purchase count, date, source, and medium.

The project also includes a small streaming demo to show how new events can be added to BigQuery and made available for a near-real-time dashboard view.

---

## 2. Tools Used

* **Google BigQuery** – stores and queries the GA4 data
* **dbt** – transforms, tests, and documents the data
* **GA4 Public Dataset** – source of the ecommerce event data
* **Git** – version control
* **Dashboard tool** – used to visualize the final attribution data

---

## 3. Data Source

The project uses the public GA4 ecommerce sample dataset:

`bigquery-public-data.ga4_obfuscated_sample_ecommerce`

The main event data is available in the GA4 `events_*` tables.

The dbt project uses the GA4 event tables as the source and creates its own transformed models inside the project dataset.

---

## 4. Data Pipeline

The dbt models are organized into three main layers:

```text
GA4 Public Dataset
        |
        v
   stg_events
        |
        v
int_user_touchpoints
int_purchases
        |
        v
First Click / Last Click
        |
        v
mart_attribution
        |
        v
    Dashboard
```

### Staging

`stg_events` contains the cleaned GA4 event data used by the rest of the pipeline.

It extracts fields such as:

* event date
* event timestamp
* event name
* user ID
* session ID
* source
* medium
* transaction ID
* purchase revenue

### Intermediate

`int_user_touchpoints` creates one marketing touchpoint for each user session.

`int_purchases` identifies purchase events and removes duplicate transaction records.

### Attribution

Two separate models calculate the attribution:

* `fct_first_click_attribution`
* `fct_last_click_attribution`

### Mart

`mart_attribution` combines the First Click and Last Click results into a single purchase-level dataset for the dashboard.

---

## 5. Attribution Logic

### User identity

`user_pseudo_id` is used as the user identifier.

### Purchase identity

`transaction_id` is used to identify purchases.

Duplicate transaction IDs are removed in the `int_purchases` model. When the same transaction appears more than once, the earliest purchase event is retained.

### Session touchpoint

A session is identified using:

`user_pseudo_id + ga_session_id`

The GA4 sample data contains events where source and medium can be missing or can change between events in the same session.

For this project, one session is therefore represented by the **first event that contains both a non-null source and medium**.

This prevents every event from being treated as a separate marketing touchpoint.

### Lookback window

A **14-day lookback window** is used for attribution.

A touchpoint is eligible only when:

* it belongs to the same `user_pseudo_id`
* it happened before the purchase
* it happened within 14 days before the purchase

The 14-day window is a project assumption for this assessment.

### First Click

First Click attribution selects the **earliest eligible touchpoint** before the purchase.

### Last Click

Last Click attribution selects the **latest eligible touchpoint** before the purchase.

### No eligible touchpoint

If a purchase does not have an eligible touchpoint within the 14-day window, the purchase is still retained with NULL attribution fields.

### Direct traffic

Direct traffic such as `(direct) / (none)` is retained as a valid touchpoint.

### Timestamp ties

The current dataset was checked for multiple valid source/medium events having the same timestamp within a user session. No such ties were found, so `event_timestamp` is currently used to order touchpoints.

---

## 6. dbt Testing

dbt tests are included for the staging, intermediate, attribution, and mart models.

Examples include:

* required fields are not NULL
* transaction IDs are unique
* purchase records are not duplicated
* attribution models contain valid purchase records

Additional SQL validation was also performed for:

* future touchpoints
* the 14-day lookback window
* First Click selecting the earliest eligible touchpoint
* Last Click selecting the latest eligible touchpoint
* one row per transaction in the final mart

All implemented dbt tests passed during development.

---

## 7. Project Dataset

The dbt models are created in the BigQuery dataset:

`assessment-28596.ga4_obfuscated_sample_ecommerce`

The main models are:

* `stg_events`
* `int_user_touchpoints`
* `int_purchases`
* `fct_first_click_attribution`
* `fct_last_click_attribution`
* `mart_attribution`
