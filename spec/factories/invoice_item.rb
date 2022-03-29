FactoryBot.define do
  factory :invoice_item, class: InvoiceItem do
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { item.unit_price }
    item
    invoice
  end
end