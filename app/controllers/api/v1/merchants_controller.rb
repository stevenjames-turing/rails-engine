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
    search_status = verify_search_params(params)
    if search_status[0] != "invalid"
       @merchant = Merchant.search_by_name(search_status[1], 1)
    end 
    if !@merchant.nil? && @merchant.count == 1
      json_response(MerchantSerializer.new(@merchant[0]))
    else
      json_response({ "data": { message: 'No matching merchant' } }, :bad_request)
    end
  end

  def find_all
    search_status = verify_search_params(params)
    if search_status[0] != "invalid"
       @merchant = Merchant.search_by_name(search_status[1])
    end 
    if !@merchant.nil? && @merchant.count >= 1
      json_response(MerchantSerializer.new(@merchant))
    else
      json_response({ "data": [] }, :bad_request)
    end
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:id])
  end
end
