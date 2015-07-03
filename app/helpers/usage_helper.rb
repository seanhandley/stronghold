module UsageHelper
  include ActionView::Helpers::FormOptionsHelper

  def usages_for_select(organization)
    organization.started_paying_at
    entries = billing_range(organization).select{|date| date.day == 1}.map do |date|
      {year: date.year, month: date.month}
    end

    coll = entries.collect do |entry|
      ["#{Date::MONTHNAMES[entry[:month]]} #{entry[:year]}", support_usage_path(entry)]
    end

    options_for_select(coll, selected: support_usage_path(month: params[:month], year: params[:year]))
  end

  def billing_range(organization)
    (organization.created_at.beginning_of_month.to_date..Date.today.end_of_month).to_a.reverse
  end

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