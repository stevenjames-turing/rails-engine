class Api::V1::ItemsController < ApplicationController
  before_action :find_item, only: %i[show destroy]
  before_action :find_item_and_merchant, only: [:update]
  before_action :set_page, only: [:index]

  def index
    json_response(ItemSerializer.new(@paginated_items))
  end

  def show
    json_response(ItemSerializer.new(@item))
  end

  def create
    item = Item.new(item_params)
    if item.save
      json_response(ItemSerializer.new(item), :created)
    else
      json_response('Error, invalid input.', :bad_request)
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
    invoice_result = @item.valid_invoice?
    @item.destroy
    Invoice.destroy(invoice_result[:id]) unless invoice_result.nil?
  end

  def find
    search_status = verify_search_params(params)
    if search_status[0] != "invalid"
       @item = Item.search_items(search_status, 1)
    end 
    if !@item.nil? && @item.count == 1
      json_response(ItemSerializer.new(@item[0]))
    else 
      json_response({ "error": {message: 'No matching items'}, "data": {data: []}}, :bad_request)
    end
  end

  def find_all
    search_status = verify_search_params(params)
    if search_status[0] != "invalid"
       @item = Item.search_items(search_status)
    end 
    if !@item.nil? && @item.count >= 1
      json_response(ItemSerializer.new(@item))
    else
      json_response({ "data": [] }, :bad_request)
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def find_item
    @item = Item.find(params[:id])
  end

  def find_item_and_merchant
    @item = Item.find(params[:id])
    @merchant = Merchant.find(@item.merchant_id)
  end

  def set_page 
    items = Item.all
    params[:per_page].nil? ? per_page = 20 : per_page = params[:per_page].to_i
    params[:page].nil? ? page_number = 1 : page_number = params[:page].to_i

    @paginated_items = paginate(items, per_page, page_number)
  end
end
