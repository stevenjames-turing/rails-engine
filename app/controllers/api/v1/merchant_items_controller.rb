class Api::V1::MerchantItemsController < ApplicationController

  def index
    if params[:item_id]
      find_merchant_and_item
      json_response(MerchantSerializer.new(@merchant))
    elsif params[:merchant_id]
      find_merchant
      json_response(ItemSerializer.new(@merchant.items))
    end
  end

  private 

    
    def find_merchant
      @merchant = Merchant.find(params[:merchant_id])
    end

    def find_merchant_and_item
      @item = Item.find(params[:item_id])
      @merchant = Merchant.find(@item.merchant_id)
    end
end