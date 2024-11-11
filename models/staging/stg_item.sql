with final as (
	select id::integer as item_id,
	       name as item_name
	  from raw.item
)

select *
  from final
