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

    OrdersSimple.relation.should == Order.select([:order_number, :memo])
  end

  it 'should handle a simple join' do
    class OrdersSimple < DataTable
      set_model Order 

      column :memo

      join :customer
    end

    customers = Arel::Table.new(:customers)
    OrdersSimple.relation.should == Order.select(:memo).joins(:customer)
  end

  it 'should handle a join with an inner column' do
    class OrdersSimple < DataTable
      set_model Order 

      column :memo

      join :customer do
        column :first_name
      end
    end

    customers = Arel::Table.new(:customers)
    OrdersSimple.new.sql.should == Order.select(:memo).joins(:customer).select(customers[:first_name]).to_sql
    OrdersSimple.relation.should == Order.select(:memo).joins(:customer).select(customers[:first_name])
  end

end
