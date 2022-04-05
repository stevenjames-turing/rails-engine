class Merchant < ApplicationRecord
  extend SearchHelper

  # Model Validations
  validates_presence_of :name

  # Model Relationships
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  def self.top_merchants_by_revenue(number)
    Merchant
      .joins(invoices: [:invoice_items, :transactions])
      .where(transactions: { result: 'success' }, invoices: { status: 'shipped' })
      .group('merchants.id')
      .select("merchants.*, SUM(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
      .order('total_revenue DESC')
      .limit(number)
  end

end
