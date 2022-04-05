class MerchantNameRevenueSerializer
  include JSONAPI::Serializer
  attributes :name

  attributes :revenue do |object|
    object.total_revenue
  end
end
