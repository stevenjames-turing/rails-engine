class WeeklyRevenueSerializer
  include JSONAPI::Serializer

  attributes :revenue do |object|
    object.revenue
  end

  attributes :week do |object|
    object.week.strftime("%Y-%m-%d")
  end
end
