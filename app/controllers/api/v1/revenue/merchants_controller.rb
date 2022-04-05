class Api::V1::Revenue::MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show]

  def index
    if params[:quantity]
      json_response(MerchantNameRevenueSerializer.new(Merchant.top_merchants_by_revenue(params[:quantity])))
    else 
      json_response({ "error": [] }, :bad_request)
    end
  end

  def show
    json_response(MerchantRevenueSerializer.new(Merchant.total_revenue(@merchant.id)[0]))
  end
  
  private

    def find_merchant
      @merchant = Merchant.find(params[:id])
    end
end 