{{ config(
    materialized = 'view'
) }}

with attribution as (
    select
        purchase_date,
        purchase_revenue,
        first_click_source,
        first_click_medium,
        last_click_source,
        last_click_medium
    from {{ ref('mart_attribution') }}
)

select
    'First Click' as attribution_model,
    SUM(purchase_revenue) as total_revenue,
    COUNT(*) as total_purchases
from attribution

union all

select
    'Last Click' as attribution_model,
    SUM(purchase_revenue) as total_revenue,
    COUNT(*) as total_purchases
from attribution