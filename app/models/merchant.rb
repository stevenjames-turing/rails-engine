class Merchant < ApplicationRecord
  # Model Validations
  validates_presence_of :name
  
end