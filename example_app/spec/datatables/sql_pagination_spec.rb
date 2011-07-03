require 'spec_helper'

describe 'pagination with count()' do

  before do
    Object.send(:remove_const, :T) rescue nil
    class T < Datatable::Base
      count("SELECT COUNT(*) + 100 FROM orders")
      sql("SELECT id FROM orders")
      columns({"orders.id" => {:type => :integer, :link_to => link_to('{{0}}', order_path('{{0}}')) }})
    end
    @params = {
      'iColumns' => 1,
      "bSearchable_0" => true
    }
    4.times{ Factory(:order) }
  end

  describe "first page" do
    before do
      @params['iDisplayStart'] = 0
      @params['iDisplayLength'] = 2
    end

    it "iTotalRecords correctly set" do
      T.query(@params).to_json['iTotalRecords'].should == 2
    end

    it "iTotalDisplayRecords correctly set" do
      T.query(@params).to_json['iTotalDisplayRecords'].should == 104
    end

    it "aaData contains dataset" do
      T.query(@params).to_json['aaData'].should == Order.all[0..1].map {|o| [o.id.to_s] }
    end
  end

  describe "second page" do
    before do
      @params['iDisplayStart'] = 2
      @params['iDisplayLength'] = 2
    end

    it "iTotalRecords correctly set" do
      T.query(@params).to_json['iTotalRecords'].should == 2
    end

    it "iTotalDisplayRecords correctly set" do
      T.query(@params).to_json['iTotalDisplayRecords'].should == 104
    end

    it "aaData contains dataset" do
      T.query(@params).to_json['aaData'].should == Order.all[2..3].map {|o| [o.id.to_s] }
    end
  end
end

describe 'pagination without count()' do
  
  before do
    Object.send(:remove_const, :T) rescue nil
    class T < Datatable::Base
      sql("SELECT id FROM orders")
      columns({"orders.id" => {:type => :integer, :link_to => link_to('{{0}}', order_path('{{0}}')) }})
    end
    @params = {
      'iColumns' => 1,
      "bSearchable_0" => true
    }
    4.times{ Factory(:order) }
  end

  describe "first page" do
    before do
      @params['iDisplayStart'] = 0
      @params['iDisplayLength'] = 2
    end

    it "iTotalRecords correctly set" do
      T.query(@params).to_json['iTotalRecords'].should == 2
    end

    it "iTotalDisplayRecords correctly set" do
      T.query(@params).to_json['iTotalDisplayRecords'].should == 4
    end

    it "aaData contains dataset" do
      T.query(@params).to_json['aaData'].should == Order.all[0..1].map {|o| [o.id.to_s] }
    end
  end


  describe "second page" do
    before do
      @params['iDisplayStart'] = 2
      @params['iDisplayLength'] = 2
    end
    it "iTotalRecords correctly set" do
      T.query(@params).to_json['iTotalRecords'].should == 2
    end

    it "iTotalDisplayRecords correctly set" do
      T.query(@params).to_json['iTotalDisplayRecords'].should == 4
    end

    it "aaData contains dataset" do
       T.query(@params).to_json['aaData'].should == Order.all[2..3].map {|o| [o.id.to_s] }
    end
  end

end


describe 'pagination with count() and where clause' do
  before do
    Object.send(:remove_const, :T) rescue nil
    class T < Datatable::Base
      count("SELECT COUNT(*) + 100 FROM orders")
      sql("SELECT id FROM orders")
      where("memo like 'foo'")
      columns({"orders.id" => {:type => :integer, :link_to => link_to('{{0}}', order_path('{{0}}')) }})
    end
    @params = {
      'iColumns' => 1,
      "bSearchable_0" => true
    }
    Factory(:order, :memo => 'foo')
    Factory(:order, :memo => 'foo')
    Factory(:order, :memo => 'foo')
    Factory(:order, :memo => 'bar')
  end

    describe "first page" do
      before do
        @params['iDisplayStart'] = 0
        @params['iDisplayLength'] = 2
      end

      it "iTotalRecords correctly set" do
        T.query(@params).to_json['iTotalRecords'].should == 2
      end

      it "iTotalDisplayRecords correctly set" do
        result = T.query(@params).to_json['iTotalDisplayRecords']
        result.should == 103
      end

      it "aaData contains dataset" do
        expected = Order.where("memo like 'foo'").all[0..1].map {|o| [o.id.to_s] }.sort
        actual = T.query(@params).to_json['aaData'].sort
        actual.should == expected
      end
    end

  describe "second page" do
    before do
      @params['iDisplayStart'] = 2
      @params['iDisplayLength'] = 2
    end

    it "iTotalRecords correctly set" do
      T.query(@params).to_json['iTotalRecords'].should == 1
    end

    it "iTotalDisplayRecords correctly set" do
      T.query(@params).to_json['iTotalDisplayRecords'].should == 103
    end

    it "aaData contains dataset" do
      expected = Order.where("memo like 'foo'").all[2..3].map {|o| [o.id.to_s] }.sort
      actual = T.query(@params).to_json['aaData'].sort
      actual.should == expected
    end
  end

end

