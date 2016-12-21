require 'clockwork'
require 'sidekiq/api'
require File.expand_path('config/boot', File.dirname(__FILE__))
require File.expand_path('config/environment', File.dirname(__FILE__))
include Clockwork

if Rails.env.production? || Rails.env.staging?
  every(2.minutes, 'live_cloud_resources') do
    LiveCloudResourcesJob.perform_later
  end

  every(90.minutes, 'usage_sync') do
    UsageJob.perform_later
  end

  every(20.minutes, 'activation_reminder') do
    ActivationReminderJob.perform_later
  end

  every(1.day, 'reaper', :at => '03:00') do
    ReaperJob.perform_later
  end

  every(4.hours, 'usage_cache_refresh') do
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

  $restart_sidekiq_mutex = Mutex.new

  every(243.minutes, 'restart_sidekiq', :thread => true) do
    return if $restart_sidekiq_mutex.locked?
    $restart_sidekiq_mutex.synchronize do
      sleep 120 * 60
      while (true)
        until (Sidekiq::ProcessSet.new.size == 0) do ; sleep 0.1 ; end
        sleep 5
        break if Sidekiq::ProcessSet.new.size == 0 # Get a clear 5 seconds of zero activity
      end
      `restart sidekiq_stronghold`
    end
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
