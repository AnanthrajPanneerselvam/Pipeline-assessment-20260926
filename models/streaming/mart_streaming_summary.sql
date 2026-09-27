{{ config(
    materialized = 'view'
) }}

select
    DATE(event_timestamp) as event_date,
    source,
    medium,
    COUNT(*) as event_count,
    COUNTIF(event_name = 'purchase') as purchase_count,
    SUM(
        CASE
            WHEN event_name = 'purchase'
            THEN revenue
            ELSE 0
        END
    ) as purchase_revenue
from {{ ref('stg_streaming_events') }}
group by
    event_date,
    source,
    medium