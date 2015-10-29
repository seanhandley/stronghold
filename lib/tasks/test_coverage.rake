require 'json'

namespace :stronghold do
  desc "Get current test coverage percent"
  task :test_coverage_percent => :environment do
    begin
      percent = JSON.parse(`cat coverage/.last_run.json`)['result']['covered_percent']
      Notifications.notify!(:test_coverage_percent, "#{percent}%. Run simplecov locally for more info.")
      exit 0
    rescue StandardError => error
      puts error.message
      exit 1
    end
  end
end