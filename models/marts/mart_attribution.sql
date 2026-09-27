{{ config(
    materialized = 'view'
) }}

with first_click as (
    select
        transaction_id,
        user_pseudo_id,
        purchase_timestamp,
        purchase_date,
        purchase_revenue,
        touchpoint_timestamp as first_click_timestamp,
        source as first_click_source,
        medium as first_click_medium
    from {{ ref('fct_first_click_attribution') }}
),

last_click as (
    select
        transaction_id,
        touchpoint_timestamp as last_click_timestamp,
        source as last_click_source,
        medium as last_click_medium
    from {{ ref('fct_last_click_attribution') }}
)

select
    f.transaction_id,
    f.user_pseudo_id,
    f.purchase_timestamp,
    f.purchase_date,
    f.purchase_revenue,
    f.first_click_timestamp,
    f.first_click_source,
    f.first_click_medium,
    l.last_click_timestamp,
    l.last_click_source,
    l.last_click_medium
from first_click f
left join last_click l
    on f.transaction_id = l.transaction_id