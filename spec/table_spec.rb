require 'spec_helper'
require 'datatable/table'

include Datatable

describe Table do

  def mock_model(stubs={})
    @mock_model ||= mock(Object, stubs.merge(:table_name => 'table', :column_names => ['col1','col2','col3']))
  end

  def mock_column(stubs={})
    @mock_column ||= mock(Object, stubs)
  end

  it "creates a new instance given valid parameters" do
    datatable = Table.new(mock_model)
    datatable.should_not be_nil
  end

  it "count returns the current number of columns" do
    datatable = Table.new(mock_model)
    datatable.count.should == 0
    datatable.column :column1
    datatable.count.should == 1
    datatable.column :column2
    datatable.count.should == 2
  end

#  describe "paginate" do
#
#  end

  #  <div class='datatable_container'>
  #    <table class='datatable'>
  #      <thead>
  #        <tr>
  #          <th>Column One</th>
  #          <th>Column two</th>
  #        </tr>
  #      </thead>
  #      <tbody>
  #      </tbody>
  #    </table>
  #  </div>
  describe "html" do
    it "yields div class='datatable_container'" do
      datatable = Table.new(mock_model)
      datatable.html.should have_selector("div.datatable_container table")
    end
    
    it "yields table class='datatable'" do
      datatable = Table.new(mock_model)
      datatable.html.should have_selector("div table.datatable")
    end

    it "yields table heading with column names" do
      datatable = Table.new(mock_model)
      datatable.html.should_not have_selector("table thead tr th")
      datatable.column :column_one
      datatable.column :column_two
      datatable.html.should have_selector("table thead tr th", :content => 'Column One')
      datatable.html.should have_selector("table thead tr th", :content => 'Column Two')
    end
    
    it "yields table with tbody" do
      datatable = Table.new(mock_model)
      datatable.html.should have_selector("table tbody")
    end

  end

  #
  #
  #
  describe "script" do
    it "returns script as string" do
      datatable = Table.new(mock_model)
      datatable.html.class.should == String
    end
  end


  #
  #
  #
  describe "render" do
    it "returns a html_safe? string" do
      datatable = Table.new(mock_model)
      datatable.render.html_safe?.should be_true
    end
  end

  #
  #
  #
  describe 'to_json' do
    it "returns 'sEcho' equal to -1 when none is supplied" do
      datatable = Table.new(mock_model)
      result = {:sEcho => -1 }
      ActiveSupport::JSON.decode(datatable.to_json({}))['sEcho'].should == -1
    end

    it "returns 'sEcho' equal to 42 when 42 is supplied" do
      datatable = Table.new(mock_model)
      params = {:sEcho => 42 }
      ActiveSupport::JSON.decode(datatable.to_json(params))['sEcho'].should == 42
    end

    it "returns 'sEcho' cast to integer value 42 when '42' is supplied" do
      datatable = Table.new(mock_model)
      params = {:sEcho => "42" }
      ActiveSupport::JSON.decode(datatable.to_json(params))['sEcho'].should == 42
    end

    it "returns 'iTotalRecords' with total number of records before filtering" do
      datatable = Table.new(mock_model)
      datatable.stub(:total_records => 42)
      ActiveSupport::JSON.decode(datatable.to_json({}))['iTotalRecords'].should == 42
    end

    it "returns 'iTotalDisplayRecords' with total number of records after filtering" do
      datatable = Table.new(mock_model)
      datatable.stub(:total_display_records => 42)
      ActiveSupport::JSON.decode(datatable.to_json({}))['iTotalDisplayRecords'].should == 42
    end

    it "returns 'aaData' with data" do
      datatable = Table.new(mock_model)
      datatable.stub(:data => [])
      ActiveSupport::JSON.decode(datatable.to_json({}))['aaData'].should == []
    end
  end


#
#  describe 'correctly orders' do
#    before(:each) do
#      @datatable = Datatable::Table.new(stub(Object, :table_name => 'table', :column_names => ['col1','col2','col3'])) do |table|
#        table.column :col1
#        table.column :col2
#        table.column :col3
#        table.column :col4  # exists in the table but not in the database
#      end
#    end
#
#    # "iSortingCols"=>"1",
#    it "nothing" do
#      @datatable.order({:iSortingCols => 0}).should == ""
#    end
#
#    # "iSortingCols"=>"1", "iSortCol_0"=>"0", "sSortDir_0"=>"asc"
#    it "column 1 ascending" do
#      @datatable.order({:iSortingCols => 1, :iSortCol_0 => 0, :sSortDir_0 => 'asc'}).should == 'table.col1 ASC'
#    end
#
#    # "iSortingCols"=>"1", "iSortCol_0"=>"0", "sSortDir_0"=>"desc",
#    it "column 1 descending" do
#      @datatable.order({:iSortingCols => 1, :iSortCol_0 => 0, :sSortDir_0 => 'desc'}).should == 'table.col1 DESC'
#    end
#
#    # "iSortingCols"=>"1", "iSortCol_0"=>"1", "sSortDir_0"=>"desc",
#    it "column 2 ascending" do
#      @datatable.order({:iSortingCols => 1, :iSortCol_0 => 1, :sSortDir_0 => 'asc'}).should == 'table.col2 ASC'
#    end
#
#    # "iSortingCols"=>"1", "iSortCol_0"=>"1", "sSortDir_0"=>"desc",
#    it "column 2 descending" do
#      @datatable.order({:iSortingCols => 1, :iSortCol_0 => 1, :sSortDir_0 => 'desc'}).should == 'table.col2 DESC'
#    end
#
#    # "iSortingCols"=>"2", "iSortCol_0"=>"0", "sSortDir_0"=>"asc", "iSortCol_1"=>"1", "sSortDir_1"=>"asc",
#    it "column 1 ascending, column 2 ascending" do
#      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'asc', :iSortCol_1 => 1, :sSortDir_1 => 'asc' }).should == 'table.col1 ASC, table.col2 ASC'
#    end
#
#    # "iSortingCols"=>"2", "iSortCol_0"=>"0", "sSortDir_0"=>"desc", "iSortCol_1"=>"1", "sSortDir_1"=>"desc",
#    it "column 1 descending, column 2 descending" do
#      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'desc', :iSortCol_1 => 1, :sSortDir_1 => 'desc' }).should == 'table.col1 DESC, table.col2 DESC'
#    end
#
#    # "iSortingCols"=>"2", "iSortCol_0"=>"0", "sSortDir_0"=>"asc", "iSortCol_1"=>"2", "sSortDir_1"=>"desc",
#    it "column 1 ascending, column 3 descending" do
#      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'asc', :iSortCol_1 => 2, :sSortDir_1 => 'desc' }).should == 'table.col1 ASC, table.col3 DESC'
#    end
#
#    # "iSortingCols"=>"2", "iSortCol_0"=>"0", "sSortDir_0"=>"desc", "iSortCol_1"=>"2", "sSortDir_2"=>"asc",
#    it "column 1 descending, column 3 ascending" do
#      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'desc', :iSortCol_1 => 2, :sSortDir_1 => 'asc' }).should == 'table.col1 DESC, table.col3 ASC'
#    end
#
#    it "only orders by columns in the datatabase" do
#      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'asc', :iSortCol_1 => 3, :sSortDir_1 => 'asc' }).should == 'table.col1 ASC'
#    end
#
#  end
end
