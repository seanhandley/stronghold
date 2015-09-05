require 'clockwork'
require File.expand_path('config/boot', File.dirname(__FILE__))
require File.expand_path('config/environment', File.dirname(__FILE__))
include Clockwork

if Rails.env.production? || Rails.env.staging?
  every(30.minutes, 'usage_sync') do
    UsageJob.perform_later
  end

  every(20.minutes, 'activation_reminder') do
    ActivationReminderJob.perform_later
  end

  every(40.minutes, 'usage_cache_refresh') do
    UsageCacheRefreshJob.perform_later
  end

  every(1.week, 'usage_report', :at => 'Monday 07:00') do
    UsageReportJob.perform_later
  end

  every(1.day, 'usage_sanity', :at => '06:00') do
    UsageSanityJob.perform_later
  end

  every(1.day, 'card_reverification', :at => '05:00') do
    CardReverificationJob.perform_later
  end

  every(203.minutes, 'restart_sidekiq', :thread => true) do
    sleep 12 * 60
    `restart sidekiq_stronghold`
  end

  every(1.day, 'billing_run', :at => '06:30') do
    BillingRunJob.perform_later if Time.now.day == 1
  end

  every(1.day, 'audit_blanks', :at => '01:00') do
    FillAuditBlanksJob.perform_later
  end

end

module Clockwork
  error_handler do |error|
    Honeybadger.notify(error)
  end
end