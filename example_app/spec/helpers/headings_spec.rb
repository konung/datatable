require 'spec_helper'

describe "headings" do

  describe "arel" do

    before do
      Object.send(:remove_const, :OrderTable) rescue nil
      class OrderTable < DataTable::Base
        set_model Order
        column :order_number
        column :memo
      end
      assign(:data_table, OrderTable)
    end

  end

  describe "raw sql" do

    before do
      Object.send(:remove_const, :OrderTable) rescue nil
      class OrderTable < DataTable::Base

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
      assign(:data_table, OrderTable)
    end

    it 'should humanize headings by default'  do
      ["Order Id", "Order Order Number", "Customer First Name", "Customer Last Name", "Order Memo"].each do |heading|
        helper.data_table_html.should contain(heading)
      end
    end

    it 'should use pretty headings when they are available' do
      OrderTable.assign_column_names(
        [
          ["orders.id", :integer, "Another heading that we specify manually"],
          ["orders.order_number", :integer, "Yet another"],
          ["customers.first_name", :string],
          ["customers.last_name", :string],
          ["orders.memo", :string, "And another"] 
      ])

      ["Another heading that we specify manually","Yet another" , "And another"].each do |heading|
        helper.data_table_html.should contain(heading)
      end
    end

  end

end
