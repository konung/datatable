require 'spec_helper'

describe 'default response intelligently when no arguments are provided' do

  # it's useful to have the datable respond with the first page and without
  # any errors when the json is browsed directly for debugging purposes

  it "should return default page size" do
    # don't return all data decide on default page size
  end
  
  it "should not barf because iColumn is not set" do
    # currently does
  end

  it "should be able to set the default sort direction" do
    # most views will have an initially defined sort order
    pending
  end

  
end