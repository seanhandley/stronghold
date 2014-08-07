module DateTimeHelper
  def long_date(date)
    output = date.strftime("%A %B ")
    output += date.day.ordinalize
    output += date.strftime(" %Y")
    output
  end

  def short_date(date)
    date.strftime("%Y.%m.%d")
  end

  def am_pm_time(time)
    time.strftime("%I:%M%p")
  end

  def long_time(time)
    time.strftime("%H:%M:%S %Z")
  end
end