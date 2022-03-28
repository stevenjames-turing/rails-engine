class Api::V1::ItemsController < ApplicationController
  before_action :find_merchant, only: [:index]

  def index
    render json: @merchant.items 
  end

  private 
    def find_merchant 
      @merchant = Merchant.find(params[:merchant_id])
    end
end