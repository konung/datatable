class OrdersIndex < DataTable

  # column :order_number

  # join :customers do
  #   column :first_name
  #   column :last_name

  #   join :sales_reps do
  #     column :first_name
  #     column :last_name
  #   end
  # end
  # column :memo

end

#    column :fullname, :select => "sales_reps.*, TRIM(BOTH FROM COALESCE(fname, ' ') || ' ' || COALESCE(lname, ' ')) AS fullname"
