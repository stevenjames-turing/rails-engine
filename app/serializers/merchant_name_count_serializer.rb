class MerchantNameCountSerializer
  include JSONAPI::Serializer
  attributes :name

  attributes :count do |object|
    object.items_sold
  end
end
