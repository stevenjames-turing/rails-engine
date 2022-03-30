class Merchant < ApplicationRecord

  # Model Validations
  validates_presence_of :name
  
  # Model Relationships
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  def self.name_search(name)
    Merchant.where("name ILIKE ?", "%#{name}%").order(name: :asc).limit(1)
  end
    
end