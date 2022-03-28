class Api::V1::ItemsController < ApplicationController
  before_action :find_item_and_merchant, only: [:show]
  # before_action :find_merchant, only: [:index]

  def index
    if params[:merchant_id]
      find_merchant
      render json: @merchant.items
    else 
      render json: Item.all
    end
  end

  def show 
    render json: @item
  end

  def create
    render json: Item.create!(item_params)
  end

  private 

    def item_params 
      params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
    end
    def find_merchant 
      @merchant = Merchant.find(params[:merchant_id])
    end

    def find_item_and_merchant
      @item = Item.find(params[:id])
      @merchant = Merchant.find(params[:merchant_id])
    end
end