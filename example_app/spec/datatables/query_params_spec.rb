require 'spec_helper'

describe 'query parameters' do

  before do
    Object.send(:remove_const, :T) rescue nil
    class T < Datatable::Base
      sql <<-SQL
        SELECT
          id,
          order_number,
          memo
        FROM
          orders
      SQL
      columns(
          {'orders.id'   => {:type => :integer}},
          {'orders.memo' => {:type => :string }}
      )
    end

    @params = {
    }
    Order.delete_all
    20.times{ Factory(:order) }
  end

#  it "raise error if uknown query parameters exist" do
#    @params['foo'] = 'bar'
#    T.query(@params)
#    lambda{ T.query(@params) }.should raise_error(Datatable::UknownQueryParameter)
#  end



end