{{ config(
    materialized='view'
) }}

with events as (

    select *
    from {{ ref('stg_events') }}
),

purchase_events as (
    select
        user_pseudo_id,
        event_date,
        event_timestamp,
        event_name,
        transaction_id,
        purchase_revenue,
        row_number() over (
            partition by transaction_id
            order by event_timestamp
        ) as rn
    from events
    where event_name = 'purchase'
      and transaction_id is not null
      and transaction_id != '(not set)'
)

select *
from purchase_events
where rn = 1