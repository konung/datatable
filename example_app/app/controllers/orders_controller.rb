class OrdersController < ApplicationController

  def index
  end

  def example1
    @datatable = Example1
    respond_to do |format|
      format.html 
      format.js { render :json => @datatable.query(params).to_json }
    end
  end

  def example2
    @datatable = Example2
    respond_to do |format|
      format.html 
      format.js { render :json => @datatable.query(params).to_json }
    end
  end

end


