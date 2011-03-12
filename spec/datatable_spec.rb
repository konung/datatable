require 'datatable/datatable'

describe Datatable do

  describe 'correctly orders' do
    before(:each) do
      @datatable = Datatable::Datatable.build(stub(Object, :table_name => 'table', :column_names => ['col1','col2','col3'])) do |table|
        table.column :col1
        table.column :col2
        table.column :col3
        table.column :col4  # exists in the table but not in the database
      end
    end

    # "iSortingCols"=>"1",
    it "nothing" do
      @datatable.order({:iSortingCols => 0}).should == ""
    end

    # "iSortingCols"=>"1", "iSortCol_0"=>"0", "sSortDir_0"=>"asc"
    it "column 1 ascending" do
      @datatable.order({:iSortingCols => 1, :iSortCol_0 => 0, :sSortDir_0 => 'asc'}).should == 'table.col1 ASC'
    end

    # "iSortingCols"=>"1", "iSortCol_0"=>"0", "sSortDir_0"=>"desc",
    it "column 1 descending" do
      @datatable.order({:iSortingCols => 1, :iSortCol_0 => 0, :sSortDir_0 => 'desc'}).should == 'table.col1 DESC'
    end

    # "iSortingCols"=>"1", "iSortCol_0"=>"1", "sSortDir_0"=>"desc",
    it "column 2 ascending" do
      @datatable.order({:iSortingCols => 1, :iSortCol_0 => 1, :sSortDir_0 => 'asc'}).should == 'table.col2 ASC'
    end

    # "iSortingCols"=>"1", "iSortCol_0"=>"1", "sSortDir_0"=>"desc",
    it "column 2 descending" do
      @datatable.order({:iSortingCols => 1, :iSortCol_0 => 1, :sSortDir_0 => 'desc'}).should == 'table.col2 DESC'
    end

    # "iSortingCols"=>"2", "iSortCol_0"=>"0", "sSortDir_0"=>"asc", "iSortCol_1"=>"1", "sSortDir_1"=>"asc",
    it "column 1 ascending, column 2 ascending" do
      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'asc', :iSortCol_1 => 1, :sSortDir_1 => 'asc' }).should == 'table.col1 ASC, table.col2 ASC'
    end
    
    # "iSortingCols"=>"2", "iSortCol_0"=>"0", "sSortDir_0"=>"desc", "iSortCol_1"=>"1", "sSortDir_1"=>"desc",
    it "column 1 descending, column 2 descending" do
      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'desc', :iSortCol_1 => 1, :sSortDir_1 => 'desc' }).should == 'table.col1 DESC, table.col2 DESC'
    end

    # "iSortingCols"=>"2", "iSortCol_0"=>"0", "sSortDir_0"=>"asc", "iSortCol_1"=>"2", "sSortDir_1"=>"desc",
    it "column 1 ascending, column 3 descending" do
      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'asc', :iSortCol_1 => 2, :sSortDir_1 => 'desc' }).should == 'table.col1 ASC, table.col3 DESC'
    end

    # "iSortingCols"=>"2", "iSortCol_0"=>"0", "sSortDir_0"=>"desc", "iSortCol_1"=>"2", "sSortDir_2"=>"asc",
    it "column 1 descending, column 3 ascending" do
      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'desc', :iSortCol_1 => 2, :sSortDir_1 => 'asc' }).should == 'table.col1 DESC, table.col3 ASC'
    end

    it "only orders by columns in the datatabase" do
      @datatable.order({:iSortingCols => 2, :iSortCol_0 => 0, :sSortDir_0 => 'asc', :iSortCol_1 => 3, :sSortDir_1 => 'asc' }).should == 'table.col1 ASC'
    end

  end
end
