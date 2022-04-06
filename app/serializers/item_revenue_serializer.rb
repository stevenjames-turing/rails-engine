class ItemRevenueSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :unit_price, :merchant_id

  attributes :revenue do |object|
    object.total_revenue
  end
end
