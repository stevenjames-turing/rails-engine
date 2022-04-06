class RevenueSerializer
  include JSONAPI::Serializer
  
  attributes :revenue do |object|
    object.total_revenue
  end
end
