class Api::V1::ItemsController < ApplicationController
  # before_action :find_merchant, only: [:index]

  def index
    if params[:merchant_id]
      find_merchant
      render json: @merchant.items
    else 
      render json: Item.all
    end
  end

  private 
    def find_merchant 
      @merchant = Merchant.find(params[:merchant_id])
    end
end