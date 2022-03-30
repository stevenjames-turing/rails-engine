class InvoiceItem < ApplicationRecord
  # Model Validations
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price

  # Model Relationships
  belongs_to :invoice
  belongs_to :item
end
