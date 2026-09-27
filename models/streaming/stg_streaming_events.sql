{{ config(
    materialized = 'view'
) }}

with source_events as (
    select
        event_id,
        event_timestamp,
        event_name,
        user_pseudo_id,
        source,
        medium,
        revenue,
        ingested_at
    from `assessment-28596.ga4_obfuscated_sample_ecommerce.streaming_events`

),

deduplicated_events as (
    select
        *,
        row_number() over (
            partition by event_id
            order by ingested_at
        ) as rn
    from source_events
)

select
    event_id,
    event_timestamp,
    event_name,
    user_pseudo_id,
    source,
    medium,
    revenue,
    ingested_at
from deduplicated_events
where rn = 1