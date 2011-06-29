require 'spec_helper'

describe 'Operations on the SQL table' do
  # Store/ retrive:
  #   data type 
  #   ordering
  #   human title

  # Column sorting
  #   input: an index to be sorted on
  #     array of columns to sort on and asc/desc
  #     [['asc', 1], ['desc', 3]]
  #
  #   need to know what index a column is
  #   and from that index need to know the column name
  #   sometimes will need the table name

  # Pass in params for sorting by various columns in various orders
  # Test that  records are returned in the correct order

  before do
    Object.send(:remove_const, :T) rescue nil

    class T < DataTable::Base
      #set_model Order
      sql <<-SQL
        SELECT id, order_number, memo
          FROM orders
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
      "bSearchable_3" => true,
      "bSortable_0" => true,
      "bSortable_1" => true,
      "bSortable_2" => true,
      "bSortable_3" => true,
      "sSearch_0" => nil,
      "sSearch_1" => nil,
      "sSearch_2" => nil,
      "sSearch_3" => nil,
      "sSearch" => nil   }

      Order.delete_all
      @orders = [*0..20].map do 
        Factory(:order, :order_number => rand(2), :memo => rand(2).even?  ? 'hello' : 'goodbye')
      end
  end

  it 'should sort by one column' do
    @params['iSortCol_0'] = 0
    @params['sSortDir_0'] = 'desc' # Assume first col is ID
    @params['iSortingCols'] = 1
    T.query(@params).to_json['aaData'][0][0].should == Order.order("id desc").first.id.to_s
  end

  it 'should sort by multiple columns' do
    @params['iSortCol_0'] = 2 # Memo
    @params['sSortDir_0'] = 'asc' 

    @params['iSortCol_1'] = 0 # ID
    @params['sSortDir_1'] = 'desc' 

    @params['iSortingCols'] = 2


    T.query(@params).to_json['aaData'][0][0].should == Order.order('memo asc, id desc')[0].id.to_s
    T.query(@params).to_json['aaData'][-1][0].should == Order.order('memo asc, id desc')[-1].id.to_s
  end

  it 'should sort ascending and descending' do
    @params['iSortCol_0'] = 2 # Memo
    @params['sSortDir_0'] = 'desc' 

    @params['iSortCol_1'] = 0 # ID
    @params['sSortDir_1'] = 'asc'

    @params['iSortingCols'] = 2


    T.query(@params).to_json['aaData'][0][0].should == Order.order('memo desc, id asc')[0].id.to_s
    T.query(@params).to_json['aaData'][-1][0].should == Order.order('memo desc, id asc')[-1].id.to_s
  end

  # Multi column searching
  #   input: a search term
  #   a way to search on all of the columns that are searchable
  #   need to know the datatype of whats in the columns
  it 'should global search' do
    # Assume memo and id are searchable
    ## Pass in params for searching by the columns that are searchable
    # Define which columns are searchable
    # search using OR for each of those cols
    # E.g. where int = num OR string LIKE str
    # Types
  end

  it 'should global search string' do
    # Memo is searchable
    @params['sSearch'] = 'hel'
    T.query(@params).to_json['aaData'][0][0].should == Order.where('memo LIKE ?', '%hel%')[0].id.to_s
    T.query(@params).to_json['aaData'][0].map(&:first).should_not include(Order.where('memo NOT LIKE ?', '%hel%').map(&:id).map(&:to_s))
  end

  it 'should global search integer' do
    # Id 
    order_id =  Order.all[rand(Order.count)].id.to_s
    @params['sSearch'] = order_id
    T.query(@params).to_json['aaData'][0][0].should == order_id
    T.query(@params).to_json['aaData'].length.should == 1
  end

  # Maybe: Test multiple results for integer

  it 'should only search columns that are searchable' do
    # ORder number is NOT searchable
    # we need to make one value exist in 2 columsn for the test
    # 
    Order.last.update_attribute(:order_number, Order.first.id)
    @params['bSearchable_1'] = false
    @params['sSearch'] = Order.first.id
    T.query(@params).to_json['aaData'][0][0].should == Order.first.id.to_s
    T.query(@params).to_json['aaData'].length.should == 1
  end

  it "shouldn't barf when no columns are searchable" do
    @params['bSearchable_0'] = false
    @params['bSearchable_1'] = false
    @params['bSearchable_2'] = false
    @params['sSearch'] = "foo"
    T.query(@params)
  end

  # TODO
  # it 'should deal w/ dates'

  # Individual column searching
  #   input: index and a search term
  #   need to know what index a col is and the col name
  #   need to know the type
  it 'should search by one string column' do
    @params['bSearchable_2'] = true  # col2 = memo
    @params['sSearch_2'] = "hello"
    T.query(@params).to_json['aaData'].length.should == Order.where('memo LIKE ?', '%hello%').count
    T.query(@params).to_json['aaData'].map { |r| r[2] }.uniq.should == ['hello']
  end

  it 'should search by one integer column' do
    @params['bSearchable_1'] = true   
    @params['sSearch_1'] = "1"
    T.query(@params).to_json['aaData'].length.should == Order.where(:order_number => 1).count
    T.query(@params).to_json['aaData'].map { |r| r[1] }.uniq.should == ["1"]
  end

  it 'should search by multiple columns' do
    @params['bSearchable_1'] = true   
    @params['sSearch_1'] = "1" 
    @params['bSearchable_2'] = true   
    @params['sSearch_2'] = "hello"
    T.query(@params).to_json['aaData'].length.should == Order.where('memo LIKE ?', '%hello%').where(:order_number => 1).count
    T.query(@params).to_json['aaData'].map { |r| r[2] }.uniq.should == ['hello']
    T.query(@params).to_json['aaData'].map { |r| r[1] }.uniq.should == ["1"]
  end

  it 'only searches - when someone actually types 0'



  # Column ordering (store/retrieve)
  #   column names in order
  #   sometimes will need to have the table name
  #   ['col.table', 'col.table']
  #   {'table.column' => :string, ...}
  it 'should allow manually setting the order of columns'
  it 'should otherwise automatically set the order' # E.g. arel

end
