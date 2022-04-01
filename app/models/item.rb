class Item < ApplicationRecord
  extend SearchHelper

  # Model Validations
  validates_presence_of :name,
                        :description,
                        :unit_price,
                        :merchant_id

  # Model Relationships
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  belongs_to :merchant

  def valid_invoice?
    ii = InvoiceItem.where(item_id: id)
    if ii.count == 1
      i = Invoice.where(id: ii[0].invoice_id)
      { id: i[0].id } if i[0].invoice_items.count == 1
    end
  end

  def self.search_items(data, count = nil)
    case data[0]
    when "name"
      Item.search_by_name(data[1], count)
    when "between"
      Item.search_between_price(data[1], data[2], count)
    when "min"
      Item.search_min_price(data[1], count)
    when "max"
      Item.search_max_price(data[1], count)
    end
  end
end
