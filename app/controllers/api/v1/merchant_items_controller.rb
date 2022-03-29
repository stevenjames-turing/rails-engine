class Api::V1::MerchantItemsController < ApplicationController
  before_action :find_merchant, only: [:index]

  def index 
    json_response(ItemSerializer.new(@merchant.items))
  end

  private 

    def find_merchant
      @merchant = Merchant.find(params[:merchant_id])
    end

    def find_item
      @item = Item.find(params[:item_id])
    end
end