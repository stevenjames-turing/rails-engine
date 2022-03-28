class Api::V1::MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show]
  
  def index
    render json: Merchant.all
  end

  def show 
    render json: @merchant 
  end

  private 

    def find_merchant
      @merchant = Merchant.find(params[:id])
    end

end