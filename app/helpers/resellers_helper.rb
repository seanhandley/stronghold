module ResellersHelper
  def usage_bar_colour(percentage)
    if percentage < 70
      'success'
    elsif percentage < 85
      'warning'
    else
      'danger'
    end
  end
end