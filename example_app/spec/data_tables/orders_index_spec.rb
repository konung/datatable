require 'spec_helper'

describe 'asfd' do

# it 'should work' do
#   Order.create!(:order_number => 32)
#   data_table = OrdersIndex.new
#   params = {}
#   json = data_table.query(params).json
#   json['aaRecords'][0][0].should == 32
# end

  it 'should store a partial sql query' do
    class OrdersSimple < DataTable
      set_model Order 

      column :order_number
      column :memo
    end

    OrdersSimple.relation.should == Order.select([:order_number, :memo])
  end

  it 'should store a partial sql query' do
    class OrdersSimple < DataTable
      set_model Order 

      column :memo

      join :customers do
        column :first_name
      end
    end

    customers = Arel::Table.new(:customers)
    OrdersSimple.relation.should == Order.select(:memo).joins(:customer).select(customers[:first_name]).to_sql
  end

end
