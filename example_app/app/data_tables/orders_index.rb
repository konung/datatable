class OrdersIndex < DataTable::Base

  #set_model Order

  sql <<-SQL
    SELECT orders.id, 
      orders.order_number,
      customers.first_name,
      customers.last_name,
      orders.memo
    FROM orders
    JOIN customers ON(customers.id = orders.customer_id)
  SQL

  columns(
    {"orders.id" => {:type => :integer}},
    # {"orders.order_number" => {:type => :integer, :link_to => link_to('{{1}}', order_path('{{0}}')) }},
    # {"customers.first_name" => {:type => :string, :link_to => link_to('{{2}}', order_path('{{0}}')) }},
    {"customers.last_name" => {:type => :string}},
    {"orders.memo" => {:type => :string}}
  )

#
#   column :id, :width => 300, :heading => 'ohai'
#
#   join :customers do
#     column ....
#   end
#
#   [
#     Column.new(:type => :integer, :width => 300, :name => 'orders.id', :heading => "ohai"),
#     Column.new(:type => :integer, :width => 300, :name => 'orders.id', :heading => "ohai")
#   ]
#
#   method {
#     "orders.id" => {:width => 300}
#   }
#
#   {
#     "orders.id" => {:type => :integer, :width => 300}
#   }
#  assign_column_names [
#    ["orders.id", :integer],
#    ["orders.order_number", :integer, "Order number"],
#    ["customers.first_name", :string],
#    ["customers.last_name", :string],
#    ["orders.memo", :string]
#  ]


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
#     #   column :first_name, :width => 300
#     #   column :last_name
#     # end
#   end
#   column :memo
# 
# end
# 
# 
