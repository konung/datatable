require 'spec_helper'

describe 'variable substitution' do

  before do
    Object.send(:remove_const, :T) rescue nil
    3.times { Factory(:order) }
    @params = { "iColumns" =>	1 }
  end

  describe "in sql clause" do
    it 'of simple variables' do
       class T < Datatable::Base
        sql <<-SQL
          SELECT
            orders.id
          FROM
            orders
          WHERE
            orders.id = {{order_id}}
        SQL
        columns(
          {'orders.id' => {:type => :integer}}
        )
       end
      order_id = Order.last.id
      T.query(@params, :order_id => order_id).to_json['aaData'].length.should == 1
      T.query(@params, :order_id => order_id).to_json['aaData'].flatten.first.should == order_id.to_s
    end

    it 'of arrays' do
       class T < Datatable::Base
        sql <<-SQL
          SELECT
            orders.id
          FROM
            orders
          WHERE
            orders.id IN {{order_ids}}
        SQL
        columns(
          {'orders.id' => {:type => :integer}}
        )
       end
       order_ids = Order.all.map{|order| order.id }.sort
       T.query(@params, :order_ids => order_ids).to_json['aaData'].flatten.sort.should == Order.order(:id).all.map {|o| o.id.to_s }
    end
  end

  it 'in count clause' do
    class T < Datatable::Base
     count <<-SQL
       SELECT
         count(orders.id)
       FROM
         orders
       WHERE
         orders.id = {{order_id}}
     SQL
     sql <<-SQL
       SELECT
         orders.id
       FROM
         orders
       WHERE
         orders.id = {{order_id}}
     SQL
     columns(
       {'orders.id' => {:type => :integer}}
     )
    end
    order_id = Order.last.id
    T.query(@params, :order_id => order_id).to_json['aaData'].length.should == 1
    T.query(@params, :order_id => order_id).to_json['aaData'].flatten.first.should == order_id.to_s
  end

  describe "in where clause" do
    it "should have a test"
  end



end
