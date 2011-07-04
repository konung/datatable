require 'spec_helper'

describe 'SQL defined datatable supports global search' do
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

  it 'string columns' do
    @params['sSearch'] = 'ello'
    expected = Order.where("memo like '%ello%'").map{|row| row.id.to_s }.sort
    actual = T.query(@params).to_json['aaData'].map{|row| row[0]}.sort
    actual.should == expected
  end

  it 'integer columns' do
    order_id =  Order.all[rand(Order.count)].id.to_s
    @params['sSearch'] = order_id
    T.query(@params).to_json['aaData'][0][0].should == order_id
    T.query(@params).to_json['aaData'].length.should == 1
  end

  it 'integer columns do not return results unless a number appears in the search string' do
    order = Order.first
    order.order_number = 0
    order.save
    @params['sSearch'] = "0"
    T.query(@params).to_json['aaData'][0][0].should == order.id.to_s
    @params['sSearch'] = "a value without the integer zero"
    T.query(@params).to_json['aaData'].should == []
  end

  it 'should only search columns that have the bSearchable_int not equal to false' do
    # Order number is set as a non searchable column with the
    # bSearchable flag below.  It should be ignored during
    # the search.  To prove that we copy the first orders id
    # value into the last orders order_number attribute.  Then
    # we do the search.  Since order_numbers are unsearchable
    # and ids are unique we should still only get a single
    # value returned
    order1 = Order.order(:id).first
    order2 = Order.order(:id).last
    order2.update_attribute(:order_number, order1.id)
    @params['bSearchable_1'] = false
    @params['sSearch'] = order1.id.to_s
    T.query(@params).to_json['aaData'].should == [[order1.id.to_s,order1.order_number.to_s, order1.memo.to_s]]
  end

  it "don't fail when no columns is searchable" do
    @params['bSearchable_0'] = false
    @params['bSearchable_1'] = false
    @params['bSearchable_2'] = false
    @params['sSearch'] = "foo"
    T.query(@params)
  end

  it "should ignore columns that are flagged bSearchable=false" do
    T.columns(
      {'orders.id'   => {:type => :integer, :bSearchable => false}},
      {'orders.order_number' => {:type => :integer }},
      {'orders.memo' => {:type => :string }}
    )
    order = Order.last
    @params['sSearch'] = order.id.to_s
    T.query(@params).to_json['aaData'].should == []
  end
end
