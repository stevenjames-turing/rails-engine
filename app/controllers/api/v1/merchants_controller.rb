class Api::V1::MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show]
  
  def index
    if params[:item_id]
      find_item 
      render json: @item.merchant
    else 
      render json: Merchant.all
    end
  end

  def show 
    render json: @merchant 
  end

  private 

    def find_merchant
      @merchant = Merchant.find(params[:id])
    end

    def find_item
      @item = Item.find(params[:item_id])
    end

end