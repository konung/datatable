require 'spec_helper'

describe 'passing variables to a Datatable' do


  before do

    Object.send(:remove_const, :T) rescue nil

   
    3.times { Factory(:order) }

    @params = {
      "iColumns" =>	1 
    }

  end

  it 'should take a substitution' do
     class T < Datatable::Base

      sql <<-SQL
        SELECT 
          orders.id
        FROM
          orders
        WHERE orders.id = {{order_id}}
      SQL

      columns(
        {'orders.id' => {:type => :integer}}
      )
    end

    T.query(@params, :order_id => Order.last.id).to_json['aaData'].length.should == 1
    T.query(@params, :order_id => Order.last.id).to_json['aaData'][0].first.should == Order.last.id.to_s
  end

  it 'should take a locals hash' do
     class T < Datatable::Base

      sql <<-SQL
        SELECT 
          orders.id
        FROM
          orders
        WHERE orders.customer_id in {{customer_ids}}
      SQL

      columns(
        {'orders.id' => {:type => :integer}}
      )
    end

    T.query(@params, :customer_ids => [1,2])
  end


end
