require 'spec_helper'

describe 'javascript options' do

  before do
    Object.send(:remove_const, :OrderTable) rescue nil
    class OrdersTable < DataTable::Base
      set_model Order
    end
  end

  it "should output default options" do
    options = OrdersTable.javascript_options("path").should == {
      'sAjaxSource' => 'path',
      'sDom' => '<"H"lfr>t<"F"ip>',
      'iDisplayLength' => 10,
      'bProcessing' => true,
      'bServerSide' => true,
      'sPaginationType' => "full_numbers"
    }
  end

  # TODO
  # test that teh options and javascript are output by the helper in the helper spec. 
  # make sure that we figure out how to set the column names in js b/c right now they are just empty columns in the header
  # make sure it works in the app
  # potentailly add helper methods like length
  # etc. ordering, filtering, etc
  it "should merge defaults with others" do
    class OrdersTable
      option 'foo', 'bar'
    end
    options = OrdersTable.javascript_options("path")['foo'].should == 'bar'
  end
  
end



