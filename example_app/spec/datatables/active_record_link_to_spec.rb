require 'spec_helper'

describe 'adding links to active record datatables' do

  before do
    Object.send(:remove_const, :T) rescue nil
    class T < Datatable::Base
      set_model Order
      column :id, :link_to => link_to('{{0}}', order_path('{{0}}'))
    end
    @params = {
      'iColumns' => 1,
      "bSearchable_0" => true
    }
  end

  it "adding link_to in block adds it to the column" do
    t = T.query(@params)
    T.columns['orders.id'][:link_to].should == "<a href=\"/orders/%7B%7B0%7D%7D\">{{0}}</a>"
  end

end
