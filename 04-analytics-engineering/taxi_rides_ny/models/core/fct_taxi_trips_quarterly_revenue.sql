{{ config(materialized="table") }}

with
    quarterly_trips_data as (
        select
            -- Revenue grouping 
            service_type,
            year, 
            quarter,
            year_quarter,
            -- Revenue calculation 
            sum(total_amount) / 1000000 as revenue_quarterly
        from {{ ref("fact_trips") }}
        where year IN (2019, 2020)  -- Since many dates differ from these years
        group by 1, 2, 3, 4
        order by service_type, year, quarter
    )
select 
    service_type,
    quarter,
    revenue_quarterly as current_revenue, 
    LAG(revenue_quarterly,4) OVER (partition by service_type ORDER BY year, quarter) AS LY_revenue,
    case 
        when lag(revenue_quarterly,4) over (partition by service_type order by year, quarter) != 0 then 
            ((revenue_quarterly 
            - lag(revenue_quarterly,4) over (partition by service_type order by year, quarter))
            / lag(revenue_quarterly,4) over (partition by service_type order by year, quarter)) * 100
        else 0
    end as yoy_revenue_growth
from quarterly_trips_data 
order by service_type, year, quarter