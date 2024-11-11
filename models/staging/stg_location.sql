with final as (
	select id::integer as location_id,
	       name as location_name
	  from raw.location
)

select *
  from final
