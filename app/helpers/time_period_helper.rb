module TimePeriodHelper
  def get_time_period(year, month)
    if year && month
      month = Time.parse("#{year}-#{month}-01 00:00:00").end_of_month
      if month > current_user.organization.created_at && month < Time.zone.now.end_of_month
        @from_date = month.beginning_of_month
        @to_date = (month.end_of_month < Time.zone.now) ? month.end_of_month : Time.zone.now
      else
        @from_date = Time.zone.now.beginning_of_month
        @to_date = Time.zone.now
      end
    else
      @from_date = Time.zone.now.beginning_of_month
      @to_date = Time.zone.now
    end
    [@from_date, @to_date]
  end
end