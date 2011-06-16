require 'spec_helper'

describe DataTable::Helper do

  before do
    Object.send(:remove_const, :OrderTable) rescue nil
    class OrderTable < DataTable::Base
      set_model Order
      column :order_number
      column :memo
    end
    assign(:data_table, OrderTable)
  end

  describe "html emitter" do

    it "should emit table" do
      helper.data_table_html.should have_selector("table#data_table")
    end

    it "should emit table with 2 columns" do
      helper.data_table_html.should have_selector("tr th:nth-child(2)")
    end

    it "should be html safe" do
      helper.data_table_html.html_safe?.should be_true
    end

  end

  describe "javascript emitter" do
    it "should output a javascript tag" do
      helper.data_table_javascript.should match(/script/)
    end

    it "should ouput the options" do
      helper.request.path = 'ohai'
      helper.data_table_javascript.should match('sAjaxSource')
      helper.data_table_javascript.should match('ohai')
    end

    it "should be JSON" do
      helper.data_table_javascript.should match(/"bProcessing":true/)
    end

    it "should be HTML safe" do
      helper.data_table_javascript.html_safe?.should be_true
    end

  end

  describe "javascript options" do

    it "should output default options" do
      helper.send(:javascript_options).should == {
        'sAjaxSource' => '',
        'sDom' => '<"H"lfr>t<"F"ip>',
        'iDisplayLength' => 10,
        'bProcessing' => true,
        'bServerSide' => true,
        'sPaginationType' => "full_numbers"
      }
    end

    it "should merge defaults with others" do
      class OrderTable
        option 'foo', 'bar'
      end
      helper.send(:javascript_options)['foo'].should == 'bar'
    end

  end

end


