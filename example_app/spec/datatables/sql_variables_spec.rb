require 'spec_helper'

describe 'variable substitution in' do

  before do
    Object.send(:remove_const, :T) rescue nil
    3.times { Factory(:order) }
    @params = { "iColumns" =>	1 }
  end

  it "sql clause handles strings" do
    class T < Datatable::Base
      count "SELECT count(orders.id) FROM orders"
      sql "SELECT orders.id FROM {{table}}"
      columns({'orders.id' => {:type => :integer}})
    end
    T.query(@params, :table => "orders").to_json['aaData'].flatten.sort.should == Order.all.map(&:id).map(&:to_s).sort
  end

  it "count clause handles strings" do
    class T < Datatable::Base
      count "SELECT count(orders.id) FROM {{table}}"
      sql "SELECT orders.id FROM orders"
      columns({'orders.id' => {:type => :integer}})
    end
    T.query(@params, :table => "orders").to_json['aaData'].flatten.sort.should == Order.all.map(&:id).map(&:to_s).sort
  end
  
  it "where clause handles strings" do
    class T < Datatable::Base
      count "SELECT count(orders.id) FROM orders"
      sql "SELECT orders.id FROM orders"
      where "{{table}}.id IS NOT NULL"
      columns({'orders.id' => {:type => :integer}})
    end
    T.query(@params, :table => "orders").to_json['aaData'].flatten.sort.should == Order.all.map(&:id).map(&:to_s).sort
  end

  it "where clause handles arrays" do
    class T < Datatable::Base
      count "SELECT count(orders.id) FROM orders"
      sql "SELECT orders.id FROM orders"
      where "orders.id in {{order_ids}}"
      columns({'orders.id' => {:type => :integer}})
    end
    T.query(@params, :order_ids => Order.all.map(&:id)).to_json['aaData'].flatten.sort.should == Order.all.map(&:id).map(&:to_s).sort
  end

  it "where clause handles empty arrays" do
    class T < Datatable::Base
      count "SELECT count(orders.id) FROM orders"
      sql "SELECT orders.id FROM orders"
      where "orders.id in {{order_ids}}"
      columns({'orders.id' => {:type => :integer}})
    end
    T.query(@params, :order_ids => []).to_json['aaData'].flatten.should == []
  end

  it "where clause handles multiple calls" do
    class T < Datatable::Base
      count "SELECT count(orders.id) FROM orders"
      sql "SELECT orders.id FROM orders"
      where "orders.id = {{order_ids}}"
      columns({'orders.id' => {:type => :integer}})
    end
    T.query(@params, :order_ids => Order.order(:id).first.id ).to_json['aaData'].flatten.sort.should == [Order.order(:id).first.id.to_s]
    T.query(@params, :order_ids => Order.order(:id).last.id ).to_json['aaData'].flatten.sort.should == [Order.order(:id).last.id.to_s]
  end


end
