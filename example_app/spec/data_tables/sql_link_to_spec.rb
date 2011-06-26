require 'spec_helper'

describe 'Creating links for SQL DataTables' do

  before do

    Object.send(:remove_const, :T) rescue nil

    class T < DataTable::Base
      sql <<-SQL
        SELECT id FROM orders
      SQL

      columns(
        {"orders.id" => {:type => :integer, :link_to => link_to('{{0}}', order_path('{{0}}')) }}
      )
    end

    @params = {
      'iColumns' => 1,
      "bSearchable_0" => true
    }
  end

  it 'should provide a link HTML element' do
    t = T.query(@params) 
    T.columns['orders.id'][:link_to].should == "<a href=\"/orders/%7B%7B0%7D%7D\">{{0}}</a>"
  end

end

