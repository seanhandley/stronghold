class UsageReportJob < ActiveJob::Base
  queue_as :default

  def perform
    from = (Time.zone.now - 1.day).beginning_of_week
    to = (Time.zone.now - 1.day).end_of_week
    Mailer.usage_report(from.to_s, to.to_s).deliver_later
  end
end