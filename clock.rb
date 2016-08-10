require 'clockwork'
require 'sidekiq/api'
require File.expand_path('config/environment', File.dirname(__FILE__))
include Clockwork

if Rails.env.production? || Rails.env.staging?
  every(2.minutes, 'live_cloud_resources') do
    LiveCloudResourcesJob.perform_later
  end

  every(4.hours, 'usage_sync') do
    UsageJob.perform_later
  end

  every(20.minutes, 'activation_reminder') do
    ActivationReminderJob.perform_later
  end

  every(1.day, 'reaper', :at => '02:00') do
    ReaperJob.perform_later
  end

  every(5.minutes, 'status_io_cache_warm') do
    StatusIOCacheWarmJob.perform_later
  end

  every(1.hour, 'load_soulmate') do
    SearchTermJob.perform_later
  end

  every(1.week, 'usage_report', :at => 'Monday 03:00') do
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

  every(5.hours, 'restart_sidekiq') do
    RestartQueueJob.perform_later
  end

  every(4.hours, 'restart_sidekiq_slow') do
    RestartSlowQueueJob.perform_later
  end

  every(1.day, 'billing_run', :at => '06:30') do
    BillingRunJob.perform_later if Time.now.day == 1
  end

  every(1.day, 'audit_blanks', :at => '01:00') do
    FillAuditBlanksJob.perform_later
  end

  every(1.day, 'organization_usage_near_threshold_alert', :at => '15:00') do
    UsageAlertJob.perform_later
  end

end

module Clockwork
  error_handler do |error|
    Honeybadger.notify(error)
  end
end
