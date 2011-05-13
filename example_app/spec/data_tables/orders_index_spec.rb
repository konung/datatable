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
    end

    data_table = OrdersSimple.new
    data_table.sql.should == 'SELECT order_number FROM `orders`'
  end



end
