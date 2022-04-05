class Api::V1::Revenue::MerchantsController < ApplicationController

  def index
    if params[:quantity]
      json_response(MerchantNameRevenueSerializer.new(Merchant.top_merchants_by_revenue(params[:quantity])))
    else 
      json_response({ "error": [] }, :bad_request)
    end
  end
  
end 