require 'spec_helper'

describe 'Use raw sql' do

  before do

    class SalesRepCustomers < DataTable::Base
      set_model SalesRep

      sql <<-SQL
        SELECT 
          sales_reps.id,
          CONCAT(first_name, last_name) AS fullname,
          sales_reps.created_at,
          COALESCE(customer_counts.value,0) AS count
        FROM 
          sales_reps
        LEFT OUTER JOIN 
          (SELECT 
             customers.sales_rep_id, 
             count(*) AS value 
           FROM customers 
           GROUP BY customers.sales_rep_id)
        AS 
          customer_counts
        ON
          customer_counts.sales_rep_id = sales_reps.id
        LIMIT {{limit}}
        OFFSET {{offset}}


      SQL
      # 
      #       column :fullname, :heading => "customer fullname" 
      # 
      #       column "Customer full name"
      # 
      #       column :memo, "asdf"
      #       headings [{:fullname => 'Customer full name'}, :count]
      #       heading ['hi', nil, nil, nil, nil, 'Customer name']
      #       columns [:foo, :bar, :baz]
    end


    @sales_reps = [Factory(:sales_rep), Factory(:sales_rep),
      Factory(:sales_rep), Factory(:sales_rep)]

    30.times do
      Factory(:customer, :sales_rep => @sales_reps[rand(4)])
    end

    @params = {}
  end

  it 'should return the correct number of records' do
    SalesRepCustomers.query(@params).to_json['aaData'].length.should == @sales_reps.length
  end

  it 'should return the records' do
    first_row = [@sales_reps[0].id, @sales_reps[0].first_name + @sales_reps[0].last_name, @sales_reps[0].read_attribute(:created_at).to_s.gsub(' UTC',''), @sales_reps[0].customers.count].map(&:to_s)
    SalesRepCustomers.query(@params).to_json['aaData'][0].should  == first_row
  end

  it 'should provide the first page' do
    @params['iDisplayStart'] = 0
    @params['iDisplayLength'] = 2

    row = [@sales_reps[0].id, @sales_reps[0].first_name + @sales_reps[0].last_name, @sales_reps[0].read_attribute(:created_at).to_s.gsub(' UTC',''), @sales_reps[0].customers.count].map(&:to_s)
    SalesRepCustomers.query(@params).to_json['iTotalRecords'].should == 2
    SalesRepCustomers.query(@params).to_json['aaData'].length.should == 2
    SalesRepCustomers.query(@params).to_json['aaData'][0].should == row
  end

  it 'should provide the second page' do
    @params['iDisplayStart'] = 2
    @params['iDisplayLength'] = 2

    row = [@sales_reps[2].id, @sales_reps[2].first_name + @sales_reps[2].last_name, @sales_reps[2].read_attribute(:created_at).to_s.gsub(' UTC',''), @sales_reps[2].customers.count].map(&:to_s)
    SalesRepCustomers.query(@params).to_json['iTotalRecords'].should == 2
    SalesRepCustomers.query(@params).to_json['aaData'].length.should == 2
    SalesRepCustomers.query(@params).to_json['aaData'][0].should == row
  end

end

describe 'Operations on the table' do
  # Store/ retrive:
  #   data type 
  #   ordering
  #   human title

  #TODO: These tests have to all work with both SQL and Arel stuff


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
      set_model Order
      sql <<-SQL
        SELECT id, order_number, memo
          FROM orders
      SQL
    end

    @params = {}
    @orders = [*0..2].map { Factory(:order) }
  end

  it 'should sort by one column' do
    @params['bSortable_0'] = true
    @params['sSortDir_0'] = 'desc' # Assume first col is ID
    T.query(@params).to_json['aaData'][0][0].should == @orders[-1].id.to_s
  end

  it 'should sort by multiple columns' do
  # @params['bSortable_0'] = true
  # @params['bSortable_0'] = true
  # @params['sSortDir_0'] = 'desc' # Assume first col is ID
  # T.query(@params).to_json.should == @orders[0]

  # @params['sSortDir_0'] = 'desc' 
  # T.query(@params).to_json.should == @orders[-1]
  end

  it 'should sort by columns in random orders (3, 2, 4)'
  it 'should sort ascending and descending'

  # Multi column searching
  #   input: a search term
  #   a way to search on all of the columns that are searchable
  #   need to know the datatype of whats in the columns
  it 'should global search' do
    ## Pass in params for searching by the columns that are searchable
    # Define which columns are searchable
    # search using OR for each of those cols
    # E.g. where int = num OR string LIKE str
    # Types
  end

  it 'should only search columns that are searchable'
  # TODO
  # it 'should deal w/ dates'

  # Individual column searching
  #   input: index and a search term
  #   need to know what index a col is and the col name
  #   need to know the type
  it 'should search by individual columns'
  it 'should search by one string column'
  it 'should search by one integer column'
  it 'should search by multiple columns'

  # Column heading naming for display
  #   ['heading name', 'heading name']
  #   strings that map to column names
  it 'should use pretty headings when they are available' do
    # Given a heading for a column
    # The html helper should ouput the right thing somehow
  end
  it 'should humanize headings by default' 


  # Column ordering (store/retrieve)
  #   column names in order
  #   sometimes will need to have the table name
  #   ['col.table', 'col.table']
  #   {'table.column' => :string, ...}
  it 'should allow manually setting the order of columns'
  it 'should otherwise automatically set the order' # E.g. arel

end
