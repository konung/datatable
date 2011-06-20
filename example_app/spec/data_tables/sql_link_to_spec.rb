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
    t.columns['orders.id'][:link_to].should == link_to('{{orders.id}}', order_path('{{orders.id}}') )
  end

  it 'should provide a hash of variables to replace and what column index to replace them with' do
    t.columns['orders.id'][:replacements].should == {
      0 => 0
    }
  end

end
