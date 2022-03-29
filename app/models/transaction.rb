class Transaction < ApplicationRecord

  # Model Validations
  validates_presence_of :invoice_id,
                        :credit_card_number,
                        :result

  # Model Relationships
  belongs_to :invoice
end