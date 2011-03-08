require 'datatable'

describe Datatable do
  it "creates new instance given valid attributes" do
    datatable = Datatable::Datatable.new
    datatable.should_not be_nil
  end
  it "bark says roof" do
    datatable = Datatable::Datatable.new
    datatable.bark.should == "roooof"
  end
end
