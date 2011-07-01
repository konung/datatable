require 'spec_helper'

describe 'variable substitution' do

  before do
    Object.send(:remove_const, :T) rescue nil
    3.times { Factory(:order) }
    @params = { "iColumns" =>	1 }
  end

  describe "in sql clause" do
    it 'allows simple variable in substitution' do
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

    it 'allows array in substitution' do
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
       pending "finish the test"
       T.query(@params, :customer_ids => [1,2])
    end
  end

  describe "in where clause" do
    it "should have a test here"
  end



end
