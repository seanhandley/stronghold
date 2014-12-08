require 'clockwork'
require File.expand_path('config/boot', File.dirname(__FILE__))
require File.expand_path('config/environment', File.dirname(__FILE__))
include Clockwork

every(30.minutes, 'usage_sync') do
  UsageWorker.perform_async
end
