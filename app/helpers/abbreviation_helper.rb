module AbbreviationHelper
  def fix_abbreviation_case(s)
    s.gsub('Ip','IP').gsub('Isp', 'ISP') 
  end
end