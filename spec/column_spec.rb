require 'spec_helper'
require 'datatable/column'

include Datatable

describe Column do

  def mock_datatable(stubs={})
    default_stubs = {
      :database_table => 'foos',
      :model_column_names => ['column1', 'column2', 'column3']
    }
    @mock_datatable ||= mock(Object, default_stubs.merge(stubs))
  end

  it "stores reference to datatable" do
    column = Column.new(mock_datatable, "column1")
    column.datatable.should == mock_datatable
  end

  it "stores reference to name" do
    column = Column.new(mock_datatable, "column1")
    column.name.should == "column1"
  end


  describe "accessor" do
    it "raises exception if no accessor is provided and 'name' is not a column name" do
      column = Column.new(mock_datatable, "not a column")
      lambda{column.accessor}.should raise_error
    end

    it "returns 'name' if no accessor is provided and 'name' is also a column name" do
      column = Column.new(mock_datatable, "column1")
      column.accessor.should == "column1"
    end

    it "returns accessor provided at creation if one was" do
      column = Column.new(mock_datatable, "column1", "accessor")
      column.accessor.should == "accessor"
    end
  end

  describe "render" do
    pending "it calls the object with the accessor"
    pending "it calls the association with the accessor"
  end
  
end