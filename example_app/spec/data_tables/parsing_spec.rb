require 'spec_helper'

describe 'parsing raw sql' do


  it 'should grab the column names' do

    class T < DataTable::Base
      set_model Order
      sql <<-SQL
       select orders.id from orders
      SQL
    end

    T.columns.should == { 'orders.id' => {:type => :integer}}

  end

end
