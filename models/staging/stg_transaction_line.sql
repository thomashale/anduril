with transaction_lines as (
	select date(transaction_date) as transaction_date,
	       transaction_id::integer as transaction_id,
	       transaction_line_id::integer as transaction_line_id,
	       transaction_type,
	       upper(type_based_document_number) as type_based_document_number,
	       upper(type_based_document_status) as type_based_document_status,
	       item_id::integer as item_id,
	       bin_id::integer as bin_id,
	       inventory_status_id::integer as inventory_status_id,
	       location_id::integer as location_id,
	       quantity::decimal(19,2) as quantity,
	       quantity as original_quantity,
	       row_number() over (partition by transaction_id, transaction_line_id, bin_id, 
					       inventory_status_id, quantity) as row_num
	  from raw.transaction_line
),

final as (
	select transaction_date,
	       transaction_id,
	       transaction_line_id,
	       transaction_type,
               type_based_document_number,
	       type_based_document_status,
	       item_id,
	       bin_id,
	       inventory_status_id,
	       location_id,
	       quantity,
	       original_quantity
          from transaction_lines
         where row_num = 1
)

select *
  from final
