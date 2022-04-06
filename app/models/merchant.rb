class Merchant < ApplicationRecord
  extend SearchHelper

  # Model Validations
  validates_presence_of :name

  # Model Relationships
  has_many :invoices
  has_many :items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices
  has_many :invoice_items, through: :invoices

  def self.top_merchants_by_revenue(number)
    Merchant
      .joins(invoices: [:invoice_items, :transactions])
      .where(transactions: { result: 'success' }, invoices: { status: 'shipped' })
      .group('merchants.id')
      .select("merchants.*, SUM(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
      .order('total_revenue DESC')
      .limit(number)
  end
  
  def self.top_merchants_by_items_sold(number)
    Merchant
      .joins(invoices: [:invoice_items, :transactions])
      .where(transactions: { result: 'success' }, invoices: { status: 'shipped' })
      .group('merchants.id')
      .select("merchants.*, SUM(invoice_items.quantity) as items_sold")
      .order('items_sold DESC')
      .limit(number)
  end

  def self.total_revenue(merchant_id)
    Merchant
    .joins(invoices: [:invoice_items, :transactions])
    .where(transactions: { result: 'success' }, invoices: { status: 'shipped' }, merchants: {id: merchant_id})
    .group('merchants.id')
    .select("merchants.*, SUM(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
  end

end
