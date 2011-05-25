class OrdersController < ApplicationController

  def index
    @data_table = OrdersIndex
    # respond_to do |format|
    #   format.html { @orders = Order.limit(10) }
    #   format.js do 
    #     render :json => DataTable.new(params).json 
    #   end

    # end
  end

end


