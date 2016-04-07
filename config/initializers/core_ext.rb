class Numeric
  def nearest_penny
    (self < 0.01 && self > 0) ? 0.01 : self
  end
end

class String
  def to_ascii
    encode(Encoding.find('ASCII'), invalid: :replace, undef: :replace, replace: '', universal_newline: true)
  end
end