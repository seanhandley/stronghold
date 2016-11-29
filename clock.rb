require 'clockwork'
require File.expand_path('config/boot', File.dirname(__FILE__))
require File.expand_path('config/environment', File.dirname(__FILE__))
include Clockwork

if Rails.env.production? || Rails.env.staging?
  every(2.minutes, 'graph_cache_warmer') do
    GraphCacheWarmerJob.perform_later
  end

  every(Billing::SYNC_INTERVAL_MINUTES.minutes, 'usage_sync') do
    UsageJob.perform_later(nil)
  end

  every(20.minutes, 'activation_reminder') do
    ActivationReminderJob.perform_later
  end

  every(1.day, 'reaper', :at => '03:00') do
    ReaperJob.perform_later
  end

  every(80.minutes, 'usage_cache_refresh') do
    UsageCacheRefreshJob.perform_later
  end

  every(5.minutes, 'status_io_cache_warm') do
    StatusIOCacheWarmJob.perform_later
  end

  every(1.hour, 'load_soulmate') do
    SoulmateJob.perform_later
  end

  every(1.week, 'usage_report', :at => 'Monday 07:00') do
    UsageReportJob.perform_later
  end

  every(1.week, 'salesforce_sync', :at => 'Monday 08:00') do
    SalesforceSyncAllJob.perform_later
  end

  every(1.day, 'usage_sanity_am', :at => '06:00') do
    UsageSanityJob.perform_later
  end

  every(1.day, 'usage_sanity_pm', :at => '14:00') do
    UsageSanityJob.perform_later
  end

  every(1.day, 'clear_stale_signups', :at => '01:00') do
    ClearStaleSignupsJob.perform_later
  end

  every(243.minutes, 'restart_sidekiq', :thread => true) do
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
