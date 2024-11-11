with final as (
	select id::integer as bin_id,
	       name as bin_name
	  from raw.bin
)

select *
  from final
