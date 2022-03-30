class Api::V1::MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show]
  
  def index
    if params[:item_id]
      find_item 
      json_response(MerchantSerializer.new(@item.merchant, { params: { relationship: true } }))
    else 
      json_response(MerchantSerializer.new(Merchant.all))
    end
  end

  def show 
    json_response(MerchantSerializer.new(@merchant))
  end

  def find
    if (params[:name]) && (params[:name] != nil) && (params[:name] != "")
      @item = Merchant.name_search(params[:name])
    else 
      @item = nil 
    end
    if @item != nil && @item.count == 1
      json_response(MerchantSerializer.new(@item[0]))
    else 
      json_response(@item, :bad_request)
    end
  end
  
  private 

    def find_merchant
      @merchant = Merchant.find(params[:id])
    end

    def find_item
      @item = Item.find(params[:item_id])
    end

end