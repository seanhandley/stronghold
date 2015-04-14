module CardBrandHelper
  def brand_to_font_awesome(brand)
    case brand.downcase
    when "american express"
      "amex"
    else
      brand.downcase
    end
  end
end