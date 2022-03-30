module SearchHelper 
  def verify_search_params(params)
    if params[:name]
      if (params[:min_price]) ||  (params[:max_price])
        ["invalid"]
      elsif (params[:name] == nil) || (params[:name] == "")
        ["invalid"]
      else
        ["name", params[:name]]
      end 
    elsif (params[:min_price]) && (params[:max_price])
      if (params[:min_price].to_i) > (params[:max_price].to_i)
        ["invalid"] 
      elsif (params[:min_price].to_i < 0) || (params[:max_price].to_i < 0)
        ["invalid"]
      else 
        ["between", params[:min_price], params[:max_price]]
      end
    elsif (params[:min_price])
      if (params[:min_price] == nil) || (params[:min_price] == "") || (params[:min_price].to_i < 0)
        ["invalid"] 
      else 
        ["min", params[:min_price]]
      end
    elsif (params[:max_price])
      if (params[:max_price] == nil) || (params[:max_price] == "") || (params[:max_price].to_i < 0)
        ["invalid"] 
      else
        ["max", params[:max_price]]
      end
    else 
      ["invalid"]
    end
  end
end