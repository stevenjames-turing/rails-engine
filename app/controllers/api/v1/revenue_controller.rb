class Api::V1::RevenueController < ApplicationController

  def index
    if params[:start] != nil && params[:start] != ""
      if params[:end] != nil && params[:end] != ""
        if params[:start] <= params[:end]
          json_response(RevenueSerializer.new(InvoiceItem.total_revenue_within_range(params[:start], params[:end])[0]))
        else 
          json_response({ "error": [] }, :bad_request)
        end
      else 
        json_response({ "error": [] }, :bad_request)
      end
    else 
      json_response({ "error": [] }, :bad_request)
    end
  end

  def unshipped
    if params[:quantity].to_i > 0
      json_response(InvoiceUnshippedOrderSerializer.new(Invoice.unshipped_revenue(params[:quantity])))
    elsif !params[:quantity]
      json_response(InvoiceUnshippedOrderSerializer.new(Invoice.unshipped_revenue(10)))
    else 
      json_response({ "error": [] }, :bad_request)
    end
  end

  def weekly
    json_response(WeeklyRevenueSerializer.new(Invoice.weekly_revenue))
  end
end 
