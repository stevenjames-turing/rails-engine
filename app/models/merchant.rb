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

end
