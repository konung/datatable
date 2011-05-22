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
end


