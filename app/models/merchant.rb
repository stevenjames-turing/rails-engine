class Merchant < ApplicationRecord
  # Model Validations
  validates_presence_of :name

  # Model Relationships
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  def self.name_search(data, count = nil)
    if count.nil?
      Merchant.where('name ILIKE ?', "%#{data[1]}%").order(name: :asc)
    else 
      Merchant.where('name ILIKE ?', "%#{data[1]}%").order(name: :asc).limit(count)
    end
  end
end
