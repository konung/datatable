require 'spec_helper'

describe 'basic query params and pagination' do

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

    @params['iColumns'] = 3

  end

  it "sEcho" do
    echo = rand(239823)
    params = {'sEcho' => echo }
    OrdersSimple.new(params).to_json['sEcho'].should == echo
  end

  it 'should return the number of records when there are no records' do
    OrdersSimple.new.to_json['iTotalRecords'].should == 0
    OrdersSimple.new.to_json['iTotalDisplayRecords'].should == 0
  end

  it 'should return the number of records' do
    3.times{ Factory(:order) }
    OrdersSimple.query(@params).to_json['iTotalRecords'].should == 3
    OrdersSimple.query(@params).to_json['iTotalDisplayRecords'].should == 3
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
    @params['iColumns'] = 3

    orders = [Factory(:order), Factory(:order)]
    OrdersComplex.query(@params).to_json['aaData'].should == orders.map { |o| [o.order_number.to_s, o.memo, o.customer.first_name]}
  end

  it 'should return valid aaData in different order' do
    class OrdersComplex < DataTable::Base
      set_model Order
      column :memo
      column :order_number
    end
    @params['iColumns'] = 2
    orders = [Factory(:order), Factory(:order)]
    OrdersComplex.query(@params).to_json['aaData'].should == orders.map { |o| [o.memo, o.order_number.to_s]}
  end

  it "should provide first page" do
    class OrdersComplex2 < DataTable::Base
      set_model Order
      column :id
    end
    @params['iColumns'] = 1

    @params['iDisplayStart'] = 0
    @params['iDisplayLength'] = 2
    orders = [Factory(:order), Factory(:order), Factory(:order), Factory(:order)]
    OrdersComplex2.query(@params).to_json['iTotalRecords'].should == 2
    OrdersComplex2.query(@params).to_json['iTotalDisplayRecords'].should == 4
    OrdersComplex2.query(@params).to_json['aaData'].should == orders[0..1].map {|o| [o.id.to_s] }
  end

  it "should provide second page" do
     class OrdersComplex3 < DataTable::Base
      set_model Order
      column :id
    end

    @params['iColumns'] = 1
    @params['iDisplayStart'] = 2
    @params['iDisplayLength'] = 2

    orders = [Factory(:order), Factory(:order), Factory(:order), Factory(:order)]
    OrdersComplex3.query(@params).to_json['iTotalRecords'].should == 2
    OrdersComplex3.query(@params).to_json['iTotalDisplayRecords'].should == 4
    OrdersComplex3.query(@params).to_json['aaData'].should == Order.all[2..3].map {|o| [o.id.to_s] }
  end

end
