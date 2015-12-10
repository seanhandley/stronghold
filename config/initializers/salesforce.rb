Restforce.configure do |config|
  config.cache = Rails.cache
  config.api_version = "32.0"
end

require_relative '../../lib/active_record/salesforce'