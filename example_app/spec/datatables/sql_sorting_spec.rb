require 'spec_helper'

describe 'query responds to sort parameters on sql defined datatable' do
  before do
    Object.send(:remove_const, :T) rescue nil
    class T < Datatable::Base
      sql <<-SQL
        SELECT
          id,
          order_number,
          memo
        FROM
          orders
      SQL
      columns(
        {'orders.id'   => {:type => :integer}},
        {'orders.order_number' => {:type => :integer}},
        {'orders.memo' => {:type => :string }}
      )
    end

    @params = {
      "iColumns" =>	4,
      "bSearchable_0" => true,
      "bSearchable_1" => true,
      "bSearchable_2" => true,
      "bSortable_0" => true,
      "bSortable_1" => true,
      "bSortable_2" => true,
      "sSearch_0" => nil,
      "sSearch_1" => nil,
      "sSearch_2" => nil,
      "sSearch" => nil    }

      Order.delete_all
      @orders = [*0..20].map do 
        Factory(:order, :order_number => (42 + rand(2)), :memo => rand(2).even?  ? 'hello' : 'goodbye')
      end
  end

  it 'sorts single column' do
    @params['iSortCol_0'] = 0
    @params['sSortDir_0'] = 'desc' # Assume first col is ID
    @params['iSortingCols'] = 1
    T.query(@params).to_json['aaData'][0][0].should == Order.order("id desc").first.id.to_s
  end

  it 'sorts multiple columns' do
    @params['iSortCol_0'] = 2 # Memo
    @params['sSortDir_0'] = 'asc' 

    @params['iSortCol_1'] = 0 # ID
    @params['sSortDir_1'] = 'desc' 

    @params['iSortingCols'] = 2


    T.query(@params).to_json['aaData'][0][0].should == Order.order('memo asc, id desc')[0].id.to_s
    T.query(@params).to_json['aaData'][-1][0].should == Order.order('memo asc, id desc')[-1].id.to_s
  end

  it 'sorts ascending and descending' do
    @params['iSortCol_0'] = 2 # Memo
    @params['sSortDir_0'] = 'desc' 

    @params['iSortCol_1'] = 0 # ID
    @params['sSortDir_1'] = 'asc'

    @params['iSortingCols'] = 2


    T.query(@params).to_json['aaData'][0][0].should == Order.order('memo desc, id asc')[0].id.to_s
    T.query(@params).to_json['aaData'][-1][0].should == Order.order('memo desc, id asc')[-1].id.to_s
  end

end
