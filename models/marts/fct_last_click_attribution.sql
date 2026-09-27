{{ config(
    materialized = 'view'
) }}

with purchases as (
    select
        user_pseudo_id,
        transaction_id,
        event_timestamp as purchase_timestamp,
        event_date as purchase_date,
        purchase_revenue
    from {{ ref('int_purchases') }}
),

touchpoints as (
    select
        user_pseudo_id,
        ga_session_id,
        touchpoint_timestamp,
        touchpoint_date,
        touchpoint_event,
        source,
        medium
    from {{ ref('int_user_touchpoints') }}
),

eligible_touchpoints as (
    select
        p.transaction_id,
        p.user_pseudo_id,
        p.purchase_timestamp,
        p.purchase_date,
        p.purchase_revenue,
        t.ga_session_id,
        t.touchpoint_timestamp,
        t.touchpoint_date,
        t.touchpoint_event,
        t.source,
        t.medium
    from purchases p
    left join touchpoints t
        on p.user_pseudo_id = t.user_pseudo_id
        and t.touchpoint_timestamp < p.purchase_timestamp
        and t.touchpoint_timestamp >= timestamp_sub(
            p.purchase_timestamp,
            interval 14 day
        )
),

ranked_touchpoints as (
    select
        *,
        row_number() over (
            partition by transaction_id
            order by touchpoint_timestamp desc
        ) as rn
    from eligible_touchpoints
)

select
    transaction_id,
    user_pseudo_id,
    purchase_timestamp,
    purchase_date,
    purchase_revenue,
    ga_session_id,
    touchpoint_timestamp,
    touchpoint_date,
    touchpoint_event,
    source,
    medium,
    'last_click' as attribution_model
from ranked_touchpoints
where rn = 1