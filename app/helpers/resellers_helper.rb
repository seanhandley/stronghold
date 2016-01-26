module ResellersHelper
  def usage_bar_colour(percentage)
    if percentage < 50
      'success'
    elsif percentage < 75
      'warning'
    else
      'danger'
    end
  end
end