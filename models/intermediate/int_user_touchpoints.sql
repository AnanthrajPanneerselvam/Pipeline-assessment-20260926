{{ config(
    materialized = 'view'
)}}

with events as (
    select *
    from {{ ref('stg_events') }}
),

session_events as (
    select
        user_pseudo_id,
        ga_session_id,
        event_timestamp,
        event_date,
        event_name,
        event_source,
        event_medium
    from events
    where user_pseudo_id is not null
      and ga_session_id is not null
      and event_source is not null
      and event_medium is not null
),

session_touchpoints as (
    select
        user_pseudo_id,
        ga_session_id,
        event_timestamp as touchpoint_timestamp,
        event_date as touchpoint_date,
        event_name as touchpoint_event,
        event_source as source,
        event_medium as medium,
        row_number() over (
            partition by user_pseudo_id, ga_session_id
            order by event_timestamp
        ) as rn
    from session_events
)

select *
from session_touchpoints
Where rn = 1