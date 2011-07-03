require 'spec_helper'

describe 'config' do
  it "shouldn't blow up when I call Datatable.config" do
    Datatable::Base.config do |config|
      config.foo = "bar"
    end
    Datatable::Base.config.foo.should == "bar"
  end
end