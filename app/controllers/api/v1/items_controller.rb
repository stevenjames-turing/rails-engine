class Api::V1::ItemsController < ApplicationController
  before_action :find_item, only: [:show, :destroy]
  before_action :find_item_and_merchant, only: [:update]

  def index
    json_response(ItemSerializer.new(Item.all, {fields: {}}))
  end

  def show 
    json_response(ItemSerializer.new(@item))
  end

  def create
    item = Item.new(item_params)
    if item.save
      json_response(ItemSerializer.new(item), :created)
    else 
      render json: "Error, invalid input."
    end
  end

  def update 
    if @item.update(item_params)
      json_response(ItemSerializer.new(@item))
    else 
      json_response(ItemSerializer.new(@item), :not_found)
    end
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

    def find_item_and_merchant
      @item = Item.find(params[:id])
      @merchant = Merchant.find(@item.merchant_id)
    end
end