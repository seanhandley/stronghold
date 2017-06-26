class UsageReportJob < ApplicationJob
  queue_as :slow

  def perform
    from = Time.zone.now.last_week.beginning_of_week
    to = Time.zone.now.last_week.end_of_week
    data = Reports::UsageReport.new(from, to).contents
    Mailer.usage_report(from.to_s, to.to_s, data).deliver_now
  end
end