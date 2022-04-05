class InvoiceItem < ApplicationRecord
  # Model Validations
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price

  # Model Relationships
  belongs_to :invoice
  belongs_to :item

  def self.total_revenue_within_range(start_date, end_date)
    InvoiceItem
      .where("invoice_items.created_at between #{Date.strptime(start_date, '%Y-%m-%d')} and #{Date.strptime(end_date, '%Y-%m-%d')}")
      .select("invoice_items.*, SUM(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
      .order('total_revenue DESC')
  end
end
