class OrdersIndex < DataTable::Base

  set_model Order

  sql <<-SQL
    SELECT orders.id, 
      orders.order_number,
      customers.first_name,
      customers.last_name,
      orders.memo
    FROM orders
    JOIN customers ON(customers.id = orders.customer_id)
  SQL

  assign_column_names [
    ["orders.id", :integer],
    ["orders.order_number", :integer],
    ["customers.first_name", :string],
    ["customers.last_name", :string],
    ["orders.memo", :string]
  ]
end

# class OrdersIndex < DataTable::Base
# 
#   set_model Order
# 
#   column :order_number
# 
#   join :customer do
#     column :first_name
#     column :last_name
# 
#     # join :sales_rep do
#     #   column :first_name
#     #   column :last_name
#     # end
#   end
#   column :memo
# 
# end
# 
# 
