module SearchHelper

  def search_by_name(data, count = nil)
    if count.nil?
      where('name ILIKE ?', "%#{data}%").order(name: :asc)
    else 
      where('name ILIKE ?', "%#{data}%").order(name: :asc).limit(count)
    end 
  end

  def search_between_price(min, max, count = nil)
    if count.nil? 
      where("unit_price between #{min} and #{max}").order(name: :asc)
    else 
      where("unit_price between #{min} and #{max}").order(name: :asc).limit(1)
    end
  end

  def search_min_price(min, count = nil)
    if count.nil? 
      where("unit_price >= #{min}").order(name: :asc)
    else 
      where("unit_price >= #{min}").order(name: :asc).limit(1)
    end
  end

  def search_max_price(max, count = nil)
    if count.nil? 
      where("unit_price <= #{max}").order(name: :asc)
    else 
      where("unit_price <= #{max}").order(name: :asc).limit(1)
    end
  end
end