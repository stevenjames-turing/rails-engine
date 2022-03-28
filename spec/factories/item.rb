FactoryBot.define do
  factory :item, class: Item do
    name { Faker::Commerce.product_name }
    sequence(:description) { |n| "Description #{n}" }
    unit_price { Faker::Commerce.price }
    merchant
  end
end