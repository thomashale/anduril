with final as (
	select date::date as date,
	       location_id::integer as location_id,
	       item_id::integer as item_id,
	       cost::decimal(19,2) as cost,
	       cost as original_cost
	  from raw.costs
)

select *
  from final
