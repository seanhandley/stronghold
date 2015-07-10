class Numeric
  def nearest_penny
    self < 0.01 ? 0.01 : self
  end
end