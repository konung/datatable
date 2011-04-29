class OrdersController < ApplicationController

  def index
    respond_to do |format|
      format.html { @orders = Order.limit(10) }

      format.js do 

        # data = Order.limit(params[:iDisplayLength]).offset(params[:iDisplayStart].to_i).includes(:customer).map do |order|
        #   [order.customer_id, order.customer.first_name, order.order_number, order.memo]
        # end

        # json = {
        #   'sEcho' =>  params[:sEcho],
        #   'iTotalRecords' => Order.count,
        #   'iTotalDisplayRecords' => Order.count,
        #   'aaData' => data
        # }

        render :json => DataTable.query(params).json #Order.limit(10).to_json

      end

    end
  end

  #  { 'sEcho' => params[:sEcho].to_i || -1,
  #   'iTotalRecords' => total_objects,
  #   'iTotalDisplayRecords'=> total_objects,
  #   'aaData' => data.map{|e| array_of(e)}
  # }.to_json

end


