require 'spec_helper'

describe 'sanitize all parameters used in sql' do

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
          {'orders.order_number' => {:type => :integer }},
          {'orders.memo' => {:type => :string }}
      )
    end

    @params = {
      "iColumns" =>	3,
      "bSearchable_0" => false,
      "bSearchable_1" => false,
      "bSearchable_2" => false,
      "bSortable_0" => false,
      "bSortable_1" => false,
      "bSortable_2" => false,
      "sSearch_0" => nil,
      "sSearch_1" => nil,
      "sSearch_2" => nil,
      "sSearch" => nil
    }
    Order.delete_all
    20.times{ Factory(:order) }
  end

  it "sanitize sSearch" do
    @params['sSearch'] = "'invalid sql"
    T.query(@params).to_json
    lambda{ T.query(@params) }.should_not raise_error
  end

  it "sanitize sSearch_#" do
    @params['bSearchable_2'] = true
    @params['sSearch_2'] = "'injected sql"
    T.query(@params)
    lambda{ T.query(@params) }.should_not raise_error
  end

  it "sanitize sSortDir_#" do
    @params['sSortDir_2'] = "'injected sql"
    T.query(@params).to_json
    lambda{ T.query(@params) }.should_not raise_error
  end

  it "sanitize iDisplayLength" do
    @params['iDisplayLength'] = "'injected sql"
    lambda{ T.query(@params) }.should_not raise_error
  end

  it "sanitize iDisplayStart" do
    @params['iDisplayStart'] = "'injected sql"
    lambda{ T.query(@params) }.should_not raise_error
  end





end