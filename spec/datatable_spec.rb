require 'datatable'

describe Datatable do
  it "creates new instance given valid attributes" do
    datatable = Datatable.new
    datatable.should_not be_nil
  end
end
