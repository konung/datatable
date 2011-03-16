require 'spec_helper'
require 'datatable/column'

include Datatable

describe Column do

  describe "accessor" do
    it "name exists and is stored at creation" do
      column = Column.new("name")
      column.name.should == "name"
    end
  end

end