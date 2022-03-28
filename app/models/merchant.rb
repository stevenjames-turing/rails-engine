class Merchant < ApplicationRecord
  # Model Validations
  validates_presence_of :name
  
  # Model Relationships
  has_many :items
    
end