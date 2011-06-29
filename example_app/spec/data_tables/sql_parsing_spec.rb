require 'spec_helper'

describe 'parsing raw sql' do


  it 'should grab the column names' do

    class T < DataTable::Base
      set_model Order
      sql <<-SQL
       SELECT orders.id, orders.memo 
         FROM orders
      SQL
    end

    T._columns.should == { 'orders.id' => {:type => :integer}, 'orders.memo' => {:type => :string}}

  end


  it 'names w/ as in them' 

  it 'no full table name in it??'

end
