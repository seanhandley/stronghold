Restforce.configure do |config|
  config.cache = Rails.cache
end

require_relative '../../lib/active_record/salesforce'