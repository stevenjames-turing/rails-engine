class Api::V1::ItemsController < ApplicationController
  before_action :find_item, only: [:show, :update, :destroy]
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
    item = Item.new(item_params)
    if item.save
      render json: item
    else 
      render json: "Error, invalid input."
    end
  end

  def update 
    render json: @item.update(item_params)
  end

  def destroy
    @item.destroy
  end

  private 

    def item_params 
      params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
    end
    def find_merchant 
      @merchant = Merchant.find(params[:merchant_id])
    end

    def find_item
      @item = Item.find(params[:id])
    end
end