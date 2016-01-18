class Numeric
  def nearest_penny
    (self < 0.01 && self > 0) ? 0.01 : self.round(2)
  end
end