class InvoiceUnshippedOrderSerializer
  include JSONAPI::Serializer
  attributes :potential_revenue do |object|
    object.potential_revenue
  end 
end
