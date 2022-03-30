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
    @item = (Merchant.name_search(params[:name]) if params[:name] && !params[:name].nil? && (params[:name] != ''))
    if !@item.nil? && @item.count == 1
      json_response(MerchantSerializer.new(@item[0]))
    else
      json_response({ "data": { message: 'No matching items' } }, :bad_request)
    end
  end

  def find_all
    @item = (Merchant.find_all_by_name(params[:name]) if params[:name] && !params[:name].nil? && (params[:name] != ''))
    if !@item.nil? && @item.count >= 1
      json_response(MerchantSerializer.new(@item))
    else
      json_response({ "data": [] }, :bad_request)
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
