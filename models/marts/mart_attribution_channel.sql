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

first_click as (
    select
        'First Click' as attribution_model,
        first_click_source as source,
        first_click_medium as medium,
        SUM(purchase_revenue) as attributed_revenue,
        COUNT(*) as attributed_purchases
    from attribution
    where first_click_source is not null
    group by
        first_click_source,
        first_click_medium
),

last_click as (
    select
        'Last Click' as attribution_model,
        last_click_source as source,
        last_click_medium as medium,
        SUM(purchase_revenue) as attributed_revenue,
        COUNT(*) as attributed_purchases
    from attribution
    where last_click_source is not null
    group by
        last_click_source,
        last_click_medium
)

select * from first_click
union all
select * from last_click