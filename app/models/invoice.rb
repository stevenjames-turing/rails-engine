class Invoice < ApplicationRecord
  # Model Validations
  validates_presence_of :status,
                        :customer_id,
                        :merchant_id

  # Model Relationships
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items

  def self.unshipped_revenue(number)
    Invoice
    .joins(:invoice_items, :transactions)
    .where(transactions: { result: 'success' }, invoices: { status: ['packaged', 'returned'] })
    .group('invoices.id')
    .select("invoices.*, SUM(invoice_items.quantity * invoice_items.unit_price) as potential_revenue")
  end
  
  def self.weekly_revenue
    Invoice
    .joins(:invoice_items, :transactions)
    .where(transactions: { result: 'success' }, invoices: { status: ['shipped'] })
    .select("date_trunc('week', invoices.created_at::date) AS week, SUM(invoice_items.quantity * invoice_items.unit_price) as revenue")
    .group('week')
    .order('week')
  end

end
