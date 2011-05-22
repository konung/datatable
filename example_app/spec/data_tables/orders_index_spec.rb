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
    class OrdersSimple < DataTable
      set_model Order 

      column :order_number
      column :memo
    end

    orders = Order.arel_table
    OrdersSimple.sql.should == Order.select(orders[:order_number]).select(orders[:memo]).to_sql
    OrdersSimple.relation.should == Order.select(orders[:order_number]).select(orders[:memo])
  end

  it 'should handle a simple join' do
    class OrdersSimple < DataTable
      set_model Order 

      column :memo

      join :customer
    end

    orders = Order.arel_table
    OrdersSimple.sql.should == Order.select(orders[:memo]).joins(:customer).to_sql
    OrdersSimple.relation.should == Order.select(orders[:memo]).joins(:customer)
  end

  it 'should handle a join with an inner column' do
    class OrdersSimple < DataTable
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
    class OrdersSimple < DataTable
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
    class OrdersComplex < DataTable
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
    class OrdersComplex < DataTable
      set_model Order
      column :memo
      column :order_number
    end
    orders = [Factory(:order), Factory(:order)]
    OrdersComplex.query(@params).as_json['aaData'].should == orders.map { |o| [o.memo, o.order_number.to_s]}
  end

  it "should provide first page" do
    class OrdersComplex2 < DataTable
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

  #TODO: Make it so that pagination works by having only the desired number of records returned

  it "sColumns"

   #{"sEcho"=>"1", "iColumns"=>"4",
  # "iDisplayStart"=>"0", "iDisplayLength"=>"10", "sSearch"=>"",
  # "bRegex"=>"false",
  # "sSearch_0"=>"", "bRegex_0"=>"false", "bSearchable_0"=>"true",
  # "sSearch_1"=>"", "bRegex_1"=>"false", "bSearchable_1"=>"true",
  # "sSearch_2"=>"", "bRegex_2"=>"false", "bSearchable_2"=>"true",
  # "sSearch_3"=>"", "bRegex_3"=>"false", "bSearchable_3"=>"true",
  #
  # "iSortingCols"=>"1",
  # "iSortCol_0"=>"0", "sSortDir_0"=>"DESC", "bSortable_0"=>"true",
  # "bSortable_1"=>"true", "bSortable_2"=>"true", "bSortable_3"=>"true",
  # "_"=>"1305745194153" }
  #end
end
