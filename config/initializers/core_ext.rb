class Numeric
  def nearest_penny
    (self < 0.01 && self > 0) ? 0.01 : self.round(4)
  end
end