class OrdersController < ApplicationController

  def index
    @datatable = OrdersIndex
    respond_to do |format|
      format.html 
      format.js { render :json => @datatable.query(params).to_json }
    end
  end

end


