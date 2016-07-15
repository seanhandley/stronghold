module DataRepresentationHelper
  def r(o)
    return o if o.is_a? String
    return o.to_s if o.is_a? Fixnum
    if o.is_a? Array
      return 'none' if o.empty?
      return o.join ', '
    end
  end
end
