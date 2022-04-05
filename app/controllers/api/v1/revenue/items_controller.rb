class Api::V1::Revenue::ItemsController < ApplicationController

  def index
    if params[:quantity].to_i > 0
      json_response(ItemRevenueSerializer.new(Item.top_items_by_revenue(params[:quantity])))
    elsif !params[:quantity]
      json_response(ItemRevenueSerializer.new(Item.top_items_by_revenue(10)))
    else 
      json_response({ "error": [] }, :bad_request)
    end
  end
end 