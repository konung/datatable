require 'spec_helper'

describe OrdersIndex do

  it 'should work' do
    Order.create!(:order_number => 32)
    data_table = OrdersIndex.new
    query = {}
    json = data_table.query(params).json
    json['aaRecords'][0][0].should == 32
  end

  it 'should return json' do

  end

end
