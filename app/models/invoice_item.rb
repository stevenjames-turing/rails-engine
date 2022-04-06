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
      .joins(invoice: [:transactions] )
      .where(transactions: { result: 'success' }, invoices: { status: 'shipped' }, invoice_items: { created_at: [start_date..end_date] })
      .select("SUM(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
      .order('total_revenue DESC')
  end
end
