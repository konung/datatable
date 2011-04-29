class OrdersController < ApplicationController

  def index
    @orders = Order.limit(10)
  end

end
