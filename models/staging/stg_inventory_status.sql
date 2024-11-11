with final as (
	select id::integer as inventory_status_id,
	       name as inventory_status_name
	  from raw.inventory_status
)

select *
  from final
