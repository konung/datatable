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
    OrdersSimple.new.sql.should == Order.select(orders[:order_number]).select(orders[:memo]).to_sql
    OrdersSimple.relation.should == Order.select(orders[:order_number]).select(orders[:memo])
  end

  it 'should handle a simple join' do
    class OrdersSimple < DataTable
      set_model Order 

      column :memo

      join :customer
    end

    orders = Order.arel_table
    OrdersSimple.new.sql.should == Order.select(orders[:memo]).joins(:customer).to_sql
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
    OrdersSimple.new.sql.should == Order.select(orders[:memo]).joins(:customer).select(customers[:first_name]).to_sql
    OrdersSimple.relation.should == Order.select(orders[:memo]).joins(:customer).select(customers[:first_name])
  end

end

describe 'query paramters' do

  before do
    class OrdersSimple < DataTable
      set_model Order
      column :memo
      join :customer do
        column :first_name
      end
    end
  end

  it "sEcho" do
    echo = rand(239823)
    params = {'sEcho' => echo }
    OrdersSimple.new(params).as_json['sEcho'].should == echo
  end

  it "sColumns"

  it "iDisplayStart"

  it "iDisplayLength"
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
