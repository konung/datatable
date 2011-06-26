require 'spec_helper'


describe DataTable::Helper do

  describe "sql test" do
    before do
      Object.send(:remove_const, :T) rescue nil
      class T < DataTable::Base
        sql <<-SQL
          SELECT id FROM orders
        SQL
#        columns(
#          {"orders.id" => {:type => :integer, :link_to => link_to('{{0}}', order_path('{{0}}')) }}
#        )
      end
      assign(:data_table, T)
    end

    describe "link_to" do
      #helper.data_table_javascript.should contain("<a href=\"/orders/%7B%7B0%7D%7D\">{{0}}</a>")
    end

  end

  describe "active record test" do

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
        'sPaginationType' => "full_numbers",
        "aoColumnDefs" => 'column_defs'
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
end


