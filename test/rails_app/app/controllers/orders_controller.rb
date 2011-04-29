class OrdersController < ApplicationController

  def index
    respond_to do |format|
      format.html { @orders = Order.limit(10) }

      format.js do 

        data = Order.limit(10).map do |order|
          [order.customer_id, order.order_number, order.memo]
        end

        json = {
          'sEcho' =>  params[:sEcho],
          'iTotalRecords' => 1,
          'iTotalDisplayRecords' => 1,
          'aaData' => data
        }

        render :json => json.to_json #Order.limit(10).to_json
      end

    end
  end

  #  { 'sEcho' => params[:sEcho].to_i || -1,
  #   'iTotalRecords' => total_objects,
  #   'iTotalDisplayRecords'=> total_objects,
  #   'aaData' => data.map{|e| array_of(e)}
  # }.to_json

end
