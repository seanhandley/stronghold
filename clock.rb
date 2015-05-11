require 'clockwork'
require File.expand_path('config/boot', File.dirname(__FILE__))
require File.expand_path('config/environment', File.dirname(__FILE__))
include Clockwork

if Rails.env.production? || Rails.env.staging?
  every(30.minutes, 'usage_sync') do
    UsageJob.perform_later
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

end

module Clockwork
  error_handler do |error|
    Honeybadger.notify(error)
  end
end