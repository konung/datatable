require 'spec_helper'

describe 'SQL defined datatable supports searching when WHERE clause exists' do
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


    it "demonstrate that you can't include a where in the base sql fragment" do
      T.sql <<-SQL
        SELECT
          id,
          order_number,
          memo
        FROM
          orders
        WHERE
          memo LIKE '%ello%'
      SQL
      @params['sSearch'] = Order.order(:id).first.id.to_s
      lambda { T.query(@params) }.should raise_error(ActiveRecord::StatementInvalid)
    end

    it "handles where in separate call" do
      T.where <<-SQL
        memo LIKE 'foo bar baz'
      SQL
      T.sql <<-SQL
        SELECT
          id,
          order_number,
          memo
        FROM
          orders
      SQL
      # create search parameters that use both global and individual
      # column search to find an order known to exist
      order = Order.order('order_number DESC').first
      @params['sSearch'] = order.id.to_s
      @params['bSearchable_1'] = true
      @params['sSearch_1'] = order.order_number.to_s

      # test to make sure it's not present in result because where clause excluded it
      T.query(@params).to_json['aaData'].should be_empty

      # modify this order so it will satisfy the query
      order.memo = "foo bar baz"
      order.save

      # test to make sure it is present in result because where clause excluded it
      T.query(@params).to_json['aaData'][0][0].should == order.id.to_s
    end

end
