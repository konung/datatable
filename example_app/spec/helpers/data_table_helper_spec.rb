require 'spec_helper'


describe Datatable::Helper do

  describe "with sql defined class" do
    before do
      Object.send(:remove_const, :T) rescue nil
      class T < Datatable::Base
        sql <<-SQL
          SELECT id FROM orders
        SQL
        columns(
          {"orders.id" => {:type => :integer, :link_to => link_to('{{0}}', order_path('{{0}}')) }}
        )
      end
      assign(:datatable, T)
    end

    describe "link_to" do
      it "contains href" do
        helper.datatable_javascript.should contain('<a href=\"/orders/%7B%7B0%7D%7D\">{{0}}</a>')
      end
    end

  end


  describe "active record test" do

    before do
      Object.send(:remove_const, :OrderTable) rescue nil
      class OrderTable < Datatable::Base
        set_model Order
        column :order_number, :link_to => link_to('{{0}}', order_path('{{0}}'))
        column :memo
      end
      assign(:datatable, OrderTable)
    end

    describe "link_to" do
      it "contains href" do
        helper.datatable_javascript.should contain('<a href=\"/orders/%7B%7B0%7D%7D\">{{0}}</a>')
      end
    end

    describe "html emitter" do

      it "should emit table" do
        helper.datatable_html.should have_selector("table#datatable")
      end

      it "should emit table with 2 columns" do
        helper.datatable_html.should have_selector("tr th:nth-child(2)")
      end

      it "should be html safe" do
        helper.datatable_html.html_safe?.should be_true
      end

      it 'should include individual column search inputs if enabled' do
        helper.datatable_html.should_not have_selector('tfoot th input')

        OrderTable.option('individual_column_searching', true)
        helper.datatable_html.should have_selector('tfoot th input')
      end

    end

    describe "javascript emitter" do
      it "should output a javascript tag" do
        helper.datatable_javascript.should match(/script/)
      end

      it "should ouput the options" do
        helper.request.path = 'ohai'
        helper.datatable_javascript.should match('sAjaxSource')
        helper.datatable_javascript.should match('ohai')
      end

      it "should be JSON" do
        helper.datatable_javascript.should match(/"bProcessing":true/)
      end

      it "should be HTML safe" do
        helper.datatable_javascript.html_safe?.should be_true
      end

    end

    describe "javascript options" do

      it "should output default options" do
        helper.send(:javascript_options).should == {
            'oLanguage' => {
                'sInfoFiltered' => ''
            },
            'sAjaxSource' => '',
            'sDom' => '<"H"lfr>t<"F"ip>',
            'iDisplayLength' => 10,
            'bProcessing' => true,
            'bServerSide' => true,
            'sPaginationType' => "full_numbers",
            'aoColumns' => "aocolumns_place_holder"
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



