{{
    config(
        materialized='table'
    )
}}

with green_tripdata as (
    select *, 
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
), 
yellow_tripdata as (
    select *, 
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
), 
unioned as (
    select * from green_tripdata
    union all 
    select * from yellow_tripdata
), 
dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select unioned.tripid, 
    unioned.vendorid, 
    unioned.service_type,
    unioned.ratecodeid, 
    unioned.pickup_locationid, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    unioned.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    unioned.pickup_datetime, 
    unioned.dropoff_datetime, 
    unioned.store_and_fwd_flag, 
    unioned.passenger_count, 
    unioned.trip_distance, 
    unioned.trip_type, 
    unioned.fare_amount, 
    unioned.extra, 
    unioned.mta_tax, 
    unioned.tip_amount, 
    unioned.tolls_amount, 
    unioned.ehail_fee, 
    unioned.improvement_surcharge, 
    unioned.total_amount, 
    unioned.payment_type, 
    unioned.payment_type_description
from unioned
inner join dim_zones as pickup_zone
on unioned.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on unioned.dropoff_locationid = dropoff_zone.locationid

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}