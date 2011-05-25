require 'spec_helper'

describe 'Data tables subclasses' do

  # it 'should work' do
  #   Order.create!(:order_number => 32)
  #   data_table = OrdersIndex.new
  #   params = {}
  #   json = data_table.query(params).json
  #   json['aaRecords'][0][0].should == 32
  # end

  it 'should select two fields' do
    class OrdersSimple < DataTable::Base
      set_model Order 

      column :order_number
      column :memo
    end

    orders = Order.arel_table
    OrdersSimple.sql.should == Order.select(orders[:order_number]).select(orders[:memo]).to_sql
    OrdersSimple.relation.should == Order.select(orders[:order_number]).select(orders[:memo])
  end

  it 'should handle a simple join' do
    class OrdersSimple < DataTable::Base
      set_model Order 

      column :memo

      join :customer
    end

    orders = Order.arel_table
    OrdersSimple.sql.should == Order.select(orders[:memo]).joins(:customer).to_sql
    OrdersSimple.relation.should == Order.select(orders[:memo]).joins(:customer)
  end

  it 'should handle a join with an inner column' do
    class OrdersSimple < DataTable::Base
      set_model Order 

      column :memo

      join :customer do
        column :first_name
      end
    end

    orders = Order.arel_table
    customers = Arel::Table.new(:customers)
    OrdersSimple.sql.should == Order.select(orders[:memo]).joins(:customer).select(customers[:first_name]).to_sql
    OrdersSimple.relation.should == Order.select(orders[:memo]).joins(:customer).select(customers[:first_name])
  end

end

describe 'query paramters' do

  before do
    class OrdersSimple < DataTable::Base
      set_model Order
      column :id
      column :memo
      join :customer do
        column :first_name
      end
    end

    @params = {}
  end

  it "sEcho" do
    echo = rand(239823)
    params = {'sEcho' => echo }
    OrdersSimple.new(params).as_json['sEcho'].should == echo
  end

  it 'should return the number of records when there are no records' do
    OrdersSimple.new.as_json['iTotalRecords'].should == 0
    OrdersSimple.new.as_json['iTotalDisplayRecords'].should == 0
  end

  it 'should return the number of records' do
    3.times{ Factory(:order) }
     OrdersSimple.query(@params).as_json['iTotalRecords'].should == 3
     OrdersSimple.query(@params).as_json['iTotalDisplayRecords'].should == 3
   end

  it 'should return valid aaData' do
    class OrdersComplex < DataTable::Base
      set_model Order
      column :order_number
      column :memo
      join :customer do
        column :first_name
      end
    end
    orders = [Factory(:order), Factory(:order)]
    OrdersComplex.query(@params).as_json['aaData'].should == orders.map { |o| [o.order_number.to_s, o.memo, o.customer.first_name]}
  end

  it 'should return valid aaData in different order' do
    class OrdersComplex < DataTable::Base
      set_model Order
      column :memo
      column :order_number
    end
    orders = [Factory(:order), Factory(:order)]
    OrdersComplex.query(@params).as_json['aaData'].should == orders.map { |o| [o.memo, o.order_number.to_s]}
  end

  it "should provide first page" do
    class OrdersComplex2 < DataTable::Base
      set_model Order
      column :id
    end
    @params['iDisplayStart'] = 0
    @params['iDisplayLength'] = 2
    orders = [Factory(:order), Factory(:order), Factory(:order), Factory(:order)]
    OrdersComplex2.query(@params).as_json['iTotalRecords'].should == 2
    OrdersComplex2.query(@params).as_json['iTotalDisplayRecords'].should == 2
    OrdersComplex2.query(@params).as_json['aaData'].should == orders[0..1].map {|o| [o.id.to_s] }
  end

  it "sColumns"


end

describe 'javascript options' do

  before do
    Object.send(:remove_const, :OrderTable) rescue nil
    class OrdersTable < DataTable::Base
      set_model Order
    end
  end

  it "should output default options" do
    options = OrdersTable.javascript_options("path").should == {
      'sAjaxSource' => 'path',
      'sDom' => '<"H"lr>t<"F"ip>',
      'iDisplayLength' => 10,
      'bProcessing' => true,
      'bServerSide' => true,
      'sPaginationType' => "full_numbers"
    }
  end

  # TODO
  # test that teh options and javascript are output by the helper in the helper spec. 
  # make sure that we figure out how to set the column names in js b/c right now they are just empty columns in the header
  # make sure it works in the app
  # potentailly add helper methods like length
  # etc. ordering, filtering, etc
  it "should merge defaults with others" do
    class OrdersTable
      option 'foo', 'bar'
    end
    options = OrdersTable.javascript_options("path")['foo'].should == 'bar'
  end
  
end



