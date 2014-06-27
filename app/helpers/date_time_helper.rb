module DateTimeHelper
  def long_date(date)
    output = date.strftime("%A %B ")
    output += date.day.ordinalize
    output += date.strftime(" %Y")
    output
  end

  def am_pm_time(time)
    time.strftime("%I:%M%p")
  end
end