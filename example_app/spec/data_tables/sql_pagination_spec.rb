require 'spec_helper'

describe 'sql pagination' do

  before do

    Object.send(:remove_const, :T) rescue nil

    class T < DataTable::Base
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

    T.query(@params).to_json['iTotalRecords'].should == 4
    T.query(@params).to_json['iTotalDisplayRecords'].should == 2
    T.query(@params).to_json['aaData'].should == orders[0..1].map {|o| [o.id.to_s] }
  end


  it "should provide second page" do
    @params['iDisplayStart'] = 2
    @params['iDisplayLength'] = 2

    T.query(@params).to_json['iTotalRecords'].should == 4
    T.query(@params).to_json['iTotalDisplayRecords'].should == 2
    T.query(@params).to_json['aaData'].should == Order.all[2..3].map {|o| [o.id.to_s] }
  end

end
