require 'spec_helper'

describe DataTable::Helper do

  before do
   Object.send(:remove_const, :OrderTable) rescue nil
   class OrderTable < DataTable::Base
     set_model Order
     column :order_number
     column :memo
#     option 'sAjaxSource', ''
#     option 'iDisplayLength', 5
#     option 'per_page', 5
   end
   assign(:data_table, OrderTable)
  end
  
  describe "html emitter" do

    it "should emit table" do
     helper.data_table_html.should have_selector("table.datatable")
    end

    it "should emit table with 2 columns" do
     helper.data_table_html.should have_selector("tr th:nth-child(2)")
    end
  end

#  describe "javascript emitter" do
#    it "should emit javascript " do
#      helper.data_table_javascript.should = ""
#    end
#  end

  # Test that javascript gets rendered

=begin
{
      sAjaxSource: "<%= orders_path %>",
      sDom: '<"H"lr>t<"F"ip>',
      iDisplayLength: 10,
      bProcessing: true,
      bServerSide: true,
      sPaginationType: "full_numbers",
      aoColumns: [
      {
        bSortable: true
      },
      {
        bSortable: true
      },
      {
        bSortable: true
      },
      {
        bSortable: true
      }],
      aaSorting: [[0, 'DESC']]
    });
  }
=end



end


