module Paginator 
  def paginate(data, per_page, page_number)
    data.limit(per_page).offset((page_number - 1) * per_page)
  end
end