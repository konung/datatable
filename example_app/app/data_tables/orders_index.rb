class OrdersIndex < DataTable::Base

  set_model Order

  column :order_number

  join :customer do
    column :first_name
    column :last_name

    # join :sales_rep do
    #   column :first_name
    #   column :last_name
    # end
  end
  column :memo

end


