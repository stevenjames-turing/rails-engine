class Api::V1::RevenueController < ApplicationController

  def index
    if params[:start] && params[:end]
      if params[:start] <= params[:end]
        json_response(RevenueSerializer.new(InvoiceItem.total_revenue_within_range(params[:start], params[:end])))
      else 
        json_response({ "error": [] }, :bad_request)
      end
    else 
      json_response({ "error": [] }, :bad_request)
    end
  end
end 
