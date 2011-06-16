require 'spec_helper'

describe 'javascript options' do

  before do
    Object.send(:remove_const, :OrderTable) rescue nil
    class OrdersTable < DataTable::Base
      set_model Order
    end
  end


  
end
