require 'spec_helper'

describe 'query responds to search parameters on sql defined datatable' do
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

  describe "global search" do
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

    it 'should only search columns that are searchable' do
      # Order number is set as a non searchable column with the
      # bSearchable flag below.  It should be ignored during
      # the search.  To prove that we copy the first orders id
      # value into the last orders order_number attribute.  Then
      # we do the search.  Since order_numbers are unsearchable
      # and ids are unique we should still only get a single
      # value returned
      Order.order(:id).last.update_attribute(:order_number, Order.order(:id).first.id)
      @params['bSearchable_1'] = false
      @params['sSearch'] = Order.first.id
      T.query(@params).to_json['aaData'][0][0].should == Order.order(:id).first.id.to_s
      T.query(@params).to_json['aaData'].length.should == 1
    end

    it "don't fail when no columns is searchable" do
      @params['bSearchable_0'] = false
      @params['bSearchable_1'] = false
      @params['bSearchable_2'] = false
      @params['sSearch'] = "foo"
      T.query(@params)
    end
  end

  describe "individual column search" do
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

    it 'should search by multiple columns' do
      @params['bSearchable_1'] = true
      @params['sSearch_1'] = "42"
      @params['bSearchable_2'] = true
      @params['sSearch_2'] = "hello"
      expected = Order.where('memo LIKE ?', '%hello%').where(:order_number => 42).map{|row| row.id.to_s }.sort
      actual = T.query(@params).to_json['aaData'].map{|row| row[0] }.sort
      actual.should == expected
    end

  end

  describe "supports where in separate clause" do

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
        memo LIKE 'some value that is not in the database'
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
    end

  end

  describe "unipmeneted specs" do
    it 'only searches - when someone actually types 0'
    it 'should allow manually setting the order of columns'
    it 'should otherwise automatically set the order' # E.g. arel
  end
end



    # TODO
    # it 'should deal w/ dates'

    # Individual column searching
    #   input: index and a search term
    #   need to know what index a col is and the col name
    #   need to know the type


#  it "should work when we have add the where separtely" do
#    T.where <<-SQL
#      WHERE
#        order_number = {{order_id}}
#    SQL
#    order_id = Order.all[rand(Order.count)].id.to_s
#    @params['sSearch'] = order_id
#    lambda { T.query(@params, :order_id => order_id) }.should raise_error(ActiveRecord::StatementInvalid)
#  end

