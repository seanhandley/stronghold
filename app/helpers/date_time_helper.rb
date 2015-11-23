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
    time.strftime("%I:%M%p %Z")
  end

  def long_time(time)
    time.strftime("%H:%M:%S %Z")
  end

  def full_month_cache_stamp(date)
    from, to = date.beginning_of_month, date.end_of_month
    timestamp_format = "%Y%m%d%H"
    "#{from.strftime(timestamp_format)}_#{to.strftime(timestamp_format)}"
  end

  def uk_office_is_open?
    uk_office_is_workday? && uk_office_is_workhour? && !uk_office_is_on_public_holiday?
  end

  def uk_office_is_workhour?
    current_hour = DateTime.now.in_time_zone('London').hour
    current_hour >= uk_office_opens_at && current_hour < uk_office_closes_at
  end

  def uk_office_is_workday?
    current_day = DateTime.now.in_time_zone('London').wday
    current_day >= uk_office_week_starts_on && current_day <= uk_office_week_ends_on
  end

  def uk_office_opens_at
    9
  end

  def uk_office_closes_at
    17
  end

  def uk_office_week_starts_on
    1
  end

  def uk_office_week_ends_on
    5
  end

  def uk_office_is_on_public_holiday?
    hols = Holidays.on(DateTime.now.in_time_zone('London'), :gb_eng, :observed)
    hols.any? ? hols.first[:name] : false
  end
end