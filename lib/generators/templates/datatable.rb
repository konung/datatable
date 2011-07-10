class <%= class_name %> < Datatable::Base

  #   sql <<-SQL
  #     SELECT
  #       orders.id,
  #       orders.order_number,
  #       customers.first_name,
  #       customers.last_name,
  #       orders.memo
  #     FROM
  #       orders
  #     JOIN
  #       customers ON customers.id = orders.customer_id
  # SQL

  # columns(
  #   {"orders.id" => {:type => :integer, :sTitle => "Id", :sWidth => '50px'}},
  #   {"orders.order_number" => {:type => :integer, :link_to => link_to('{{1}}', order_path('{{0}}')),:sTitle => 'Order Number', :sWidth => '125px'  }},
  #   {"customers.first_name" => {:type => :string, :link_to => link_to('{{2}}', order_path('{{0}}')),:sWidth => '200px' }},
  #   {"customers.last_name" => {:type => :string,:sWidth => '200px'}},
  #   {"orders.memo" => {:type => :string }}
  # )
  # option('bJQueryUI', true)
  # option('individual_column_searching', true)
  # #option('sDom', '<"H"lrf>t<"F"ip>')    # use with pagination
  # # to use pagination comment out following and enable previous line
  # option('sDom', '<"clear"><"H"Trf>t<"F"i>')
  # option('bScrollInfinite', true)
  # option('bScrollCollapse', true)
  # option('sScrollY', '200px')

end

