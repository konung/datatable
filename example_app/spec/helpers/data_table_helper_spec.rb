require 'spec_helper'

describe DataTable::Helper do
  describe "html emitter" do
    before do
     Object.send(:remove_const, :OrderTable) rescue nil
     class OrderTable < DataTable::Base
       set_model Order
       column :order_number
       column :memo
     end
     assign(:data_table, OrderTable)
    end

    it "should emit table" do
     helper.data_table_html.should have_selector("table.datatable")
    end

    it "should emit table with 2 columns" do
     helper.data_table_html.should have_selector("tr th:nth-child(2)")
    end
  end

  describe "hash genarator" do
    before do

    end

    it "should set sAjaxSource"
    it "should set sDom"
    it "should set iDisplayLength"
    it "should set bProcessing"
    it "should set bServerSide"
    it "should set sPaginationType"
    it "should set aoColumns"
  end

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


