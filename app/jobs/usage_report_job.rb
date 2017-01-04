class UsageReportJob < ApplicationJob
  queue_as :default

  def perform
    from = (Time.zone.now - 1.day).beginning_of_week
    to = (Time.zone.now - 1.day).end_of_week
    data = Reports::UsageReport.new(from, to).contents
    Mailer.usage_report(from.to_s, to.to_s, data).deliver_now
  end
end