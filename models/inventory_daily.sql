with transaction_totals_by_date as (
	select transaction_date as date,
	       location_id,
	       bin_id,
	       item_id,
	       inventory_status_id,
	       sum(quantity) as sum_quantity
	  from anduril.stg_transaction_line
      group by transaction_date, location_id, bin_id, item_id, inventory_status_id
),

running_total_quantities as (
	select date,
	       location_id,
	       bin_id,
	       item_id,
	       inventory_status_id,
	       sum(sum_quantity) over (partition by location_id, bin_id, item_id, inventory_status_id 
					   order by date rows between unbounded preceding 
								  and current row) as quantity
	  from transaction_totals_by_date
),

costs as (
	select date,
	       location_id,
	       item_id,
               cost,
	       coalesce(
		   lead(date) over (partition by location_id, item_id order by date)
		   , current_date + 1) as lead_date
	  from anduril.stg_cost
),

running_totals_with_value as (
	select totals.*,
	       round(totals.quantity * costs.cost, 2) as value
	  from running_total_quantities as totals
	  left join costs
	    on totals.location_id = costs.location_id
	   and totals.item_id = costs.item_id
	   and (totals.date between costs.date and costs.lead_date - 1)
),

final as (
	select totals.date,
	       location.location_id,
               location.location_name,
	       bin.bin_id,
	       bin.bin_name,
	       item.item_id,
	       item.item_name,
	       status.inventory_status_id,
	       status.inventory_status_name,
	       totals.quantity,
	       totals.value
	  from running_totals_with_value as totals
	  left join anduril.stg_location as location
	 using (location_id)
	  left join anduril.stg_bin as bin
	 using (bin_id)
	  left join anduril.stg_item as item
	 using (item_id)
	  left join anduril.stg_inventory_status as status
	 using (inventory_status_id)
)

select *
  from final
