FactoryBot.define do
  factory :item, class: Item do
    name { Faker::Commerce.product_name }
    description { Faker::Coffee.notes }
    unit_price { Faker::Commerce.price }
    merchant
  end
end