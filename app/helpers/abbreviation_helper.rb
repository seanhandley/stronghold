module AbbreviationHelper
  def fix_abbreviation_case(s)
    s.gsub('Ip','IP').gsub('Isp', 'ISP').
      gsub('Rams', 'MB RAM').gsub('Floatingip', 'Floating IP').
      gsub('Gigabytes', 'GB')
  end
end