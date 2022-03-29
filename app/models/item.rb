class Item < ApplicationRecord

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
      i = Invoice.where(id: ii[0].id)
      if i[0].invoice_items.count == 1
        {id: i[0].id}
      else 
        nil 
      end
    end
  end
end