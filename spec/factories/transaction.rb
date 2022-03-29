FactoryBot.define do
  factory :transaction, class: Transaction do
    result { 'success' }
    credit_card_number { aker::Finance.credit_card }
    credit_card_expiration_date { Faker::Date.between(from: 1.year.from_now, to: 3.year.from_now) }
    invoice
  end
end