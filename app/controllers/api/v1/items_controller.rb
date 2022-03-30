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
    invoice_result = @item.valid_invoice?
    @item.destroy
    if invoice_result != nil
      Invoice.destroy(invoice_result[:id])
    end
  end

  def find
    if (params[:name]) && (params[:min_price])
      @item = nil 
    elsif (params[:name]) && (params[:max_price])
      @item = nil 
    elsif (params[:name]) && (params[:name] != nil) && (params[:name] != "")
      @item = Item.name_search(params[:name])
    elsif (params[:min_price]) && (params[:max_price])
      @item = Item.price_search(params[:min_price], params[:max_price])
    elsif (params[:min_price])
      @item = Item.price_search(params[:min_price], nil)
    elsif params[:max_price]
      @item = Item.price_search(nil, params[:max_price])
    end

    if @item != nil && @item.count == 1
      json_response(ItemSerializer.new(@item[0]))
    else 
      json_response(ItemSerializer.new(@item), :bad_request)
    end
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