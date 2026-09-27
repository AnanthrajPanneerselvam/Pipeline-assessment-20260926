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
),

max_date as (
    select
        max(purchase_date) as latest_purchase_date
    from attribution
)

select
    a.purchase_date,
    SUM(a.purchase_revenue) as total_revenue,
    SUM(
        CASE
            WHEN a.first_click_source IS NOT NULL
            THEN a.purchase_revenue
            ELSE 0
        END
    ) as first_click_revenue,
    SUM(
        CASE
            WHEN a.last_click_source IS NOT NULL
            THEN a.purchase_revenue
            ELSE 0
        END
    ) as last_click_revenue,
    COUNT(*) as total_purchases
from attribution a
cross join max_date m
where a.purchase_date >= DATE_SUB(
    m.latest_purchase_date,
    INTERVAL 13 DAY
)
group by a.purchase_date