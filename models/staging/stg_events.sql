{{ config(
    materialized='view'
    ) }}

with source as (
    select *
    from {{ source('ga4', 'events_*') }})

select
        parse_date('%Y%m%d', event_date)   as event_date,
        timestamp_micros(event_timestamp)  as event_timestamp,
        event_name,
        user_pseudo_id,
-- session id/number inside the repeated event_params array
        (select value.int_value from unnest(event_params) where key = 'ga_session_id')     as ga_session_id,
        (select value.int_value from unnest(event_params) where key = 'ga_session_number') as ga_session_number,
        (select value.string_value from unnest(event_params) where key = 'source') as event_source,
        (select value.string_value from unnest(event_params) where key = 'medium') as event_medium,
-- user-level first-touch acquisition (recorded once per user, repeated on every event)
        traffic_source.source   as user_acquisition_source,
        traffic_source.medium   as user_acquisition_medium,
        ecommerce.transaction_id    as transaction_id,
        ecommerce.purchase_revenue  as purchase_revenue
from source