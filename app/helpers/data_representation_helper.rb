module DataRepresentationHelper
  def r(o)
    return o if o.is_a? String
    if o.is_a? Array
      return 'none' if o.empty?
      return o.join ', '
    end
  end
end