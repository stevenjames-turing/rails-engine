class Item < ApplicationRecord

  # Model Validations
  validates_presence_of :name, :description, :unit_price

  # Model Relationships
  belongs_to :merchant 
  
end