require 'spec_helper'
require 'datatable/table'

include Datatable

describe Table do

  it "creates a new instance given valid parameters" do
    datatable = Table.new
    datatable.should_not be_nil
  end

  describe "html" do
    it "yields div with attribute class='datatable_container'" do
      datatable = Table.new
      datatable.html.should have_selector("div.datatable_container table")
    end

    it "yields table with attribute class='datatable'" do
      datatable = Table.new
      datatable.html.should have_selector("div table.datatable")
    end

    it "yields table with tbody" do
      datatable = Table.new
      datatable.html.should have_selector("table tbody")
    end

  end

  #
  describe "javascript" do
    it "returns javascript as string" do
      datatable = Table.new
      datatable.html.class.should == String
    end
  end

  #
  #
  #
  describe "render" do
    it "returns a html_safe? string" do
      datatable = Table.new
      datatable.render.html_safe?.should be_true
    end
  end

  #
  #
  #
  describe 'to_json' do
    it "returns a hash" do
      datatable = Table.new
      ActiveSupport::JSON.decode(datatable.to_json({})).should == {}
    end
  end

end
