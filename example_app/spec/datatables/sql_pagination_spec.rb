require 'spec_helper'

describe 'manual sql pagination' do

  before do

    Object.send(:remove_const, :T) rescue nil

    class T < Datatable::Base

      count <<-SQL
       SELECT COUNT(*) + 100 FROM orders
      SQL

      sql <<-SQL
        SELECT id FROM orders
      SQL

      columns(
        {"orders.id" => {:type => :integer, :link_to => link_to('{{0}}', order_path('{{0}}')) }}
      )
    end

    @params = {
      'iColumns' => 1,
      "bSearchable_0" => true
    }

    4.times{ Factory(:order) }
  end

  it "should provide first page" do
    @params['iDisplayStart'] = 0
    @params['iDisplayLength'] = 2

    T.query(@params).to_json['iTotalRecords'].should == 2
    T.query(@params).to_json['iTotalDisplayRecords'].should == 104 # + 100 to make sure we are actually using the count 
    T.query(@params).to_json['aaData'].should == Order.all[0..1].map {|o| [o.id.to_s] }
  end


  it "should provide second page" do
    @params['iDisplayStart'] = 2
    @params['iDisplayLength'] = 2

    T.query(@params).to_json['iTotalRecords'].should == 2
    T.query(@params).to_json['iTotalDisplayRecords'].should == 104
    T.query(@params).to_json['aaData'].should == Order.all[2..3].map {|o| [o.id.to_s] }
  end

end


describe 'automatic sql pagination' do

  before do

    Object.send(:remove_const, :T) rescue nil

    class T < Datatable::Base
      sql <<-SQL
        SELECT id FROM orders
      SQL

      columns(
        {"orders.id" => {:type => :integer, :link_to => link_to('{{0}}', order_path('{{0}}')) }}
      )
    end

    @params = {
      'iColumns' => 1,
      "bSearchable_0" => true
    }

    4.times{ Factory(:order) }
  end

  it "should provide first page" do
    @params['iDisplayStart'] = 0
    @params['iDisplayLength'] = 2

    T.query(@params).to_json['iTotalRecords'].should == 2
    T.query(@params).to_json['iTotalDisplayRecords'].should == 4
    T.query(@params).to_json['aaData'].should == Order.all[0..1].map {|o| [o.id.to_s] }
  end


  it "should provide second page" do
    @params['iDisplayStart'] = 2
    @params['iDisplayLength'] = 2

    T.query(@params).to_json['iTotalRecords'].should == 2
    T.query(@params).to_json['iTotalDisplayRecords'].should == 4
    T.query(@params).to_json['aaData'].should == Order.all[2..3].map {|o| [o.id.to_s] }
  end

end
