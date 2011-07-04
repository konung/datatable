require 'spec_helper'

describe 'SQL defined datatable supports individual column search' do
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

    it 'should search by one string column' do
      @params['bSearchable_2'] = true  # col2 = memo
      @params['sSearch_2'] = "hello"
      T.query(@params).to_json['aaData'].length.should == Order.where('memo LIKE ?', '%hello%').count
      T.query(@params).to_json['aaData'].map { |r| r[2] }.uniq.should == ['hello']
    end

    it 'should search order number column for integer value' do
      @params['bSearchable_1'] = true
      @params['sSearch_1'] = "42"
      expected = Order.where(:order_number => 42 ).map{|row| row.id.to_s }.sort
      actual = T.query(@params).to_json['aaData'].map{|row| row[0]}.sort
      actual.should == expected
    end

    it 'integer columns do not return results unless a number appears in the search string' do
      order = Order.first
      order.order_number = 0
      order.save
      @params['bSearchable_1'] = true
      @params['sSearch_1'] = "0"
      T.query(@params).to_json['aaData'][0][0].should == order.id.to_s
      @params['sSearch_1'] = "a value without the integer zero"
      T.query(@params).to_json['aaData'].should == []
    end


    it 'should search by multiple columns' do
      @params['bSearchable_1'] = true
      @params['sSearch_1'] = "42"
      @params['bSearchable_2'] = true
      @params['sSearch_2'] = "hello"
      expected = Order.where('memo LIKE ?', '%hello%').where(:order_number => 42).map{|row| row.id.to_s }.sort
      actual = T.query(@params).to_json['aaData'].map{|row| row[0] }.sort
      actual.should == expected
    end

    it "should ignore columns that are flagged bSearchable=false" do
      T.columns(
        {'orders.id'   => {:type => :integer, :bSearchable => false}},
        {'orders.order_number' => {:type => :integer}},
        {'orders.memo' => {:type => :string }}
      )
      @params['bSearchable_0'] = true
      @params['sSearch_0'] = Order.last.id
      lambda { T.query(@params) }.should raise_error
    end

end
