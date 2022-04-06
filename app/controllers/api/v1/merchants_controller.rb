class Api::V1::MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show]
  before_action :set_page, only: [:index]


  def index
    json_response(MerchantSerializer.new(@paginated_merchants))
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

  def most_items
    if params[:quantity]
      json_response(MerchantNameCountSerializer.new(Merchant.top_merchants_by_items_sold(params[:quantity])))
    else 
      json_response({ "error": [] }, :bad_request)
    end
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:id])
  end

  def set_page 
    items = Merchant.all
    params[:per_page].nil? ? per_page = 20 : per_page = params[:per_page].to_i
    params[:page].nil? ? page_number = 1 : page_number = params[:page].to_i

    @paginated_merchants = paginate(items, per_page, page_number)
  end
end
