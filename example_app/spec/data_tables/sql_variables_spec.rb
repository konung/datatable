require 'spec_helper'

describe 'passing variables to a DataTable' do


  before do

    Object.send(:remove_const, :T) rescue nil

    class T < DataTable::Base

      sql <<-SQL
        SELECT 
          orders.id
        FROM
          orders
        WHERE orders.customer_id in ({{customer_ids}})
      SQL

      columns(
        {'orders.id' => {:type => :integer}}
      )
    end

    3.times { Factory(:order) }

    @params = {
      "iColumns" =>	1 
    }

  end

  it 'should take a substitution' do
    T.query(@params, :order_id => Order.last.id).to_json('aaData').length.should == 1
    T.query(@params, :order_id => Order.last.id).to_json('aaData')[0].should == Order.last
  end

  it 'should take a locals hash' do
    T.query(@params, :customer_ids => [1,2], :something_else => 3)
  end


end
