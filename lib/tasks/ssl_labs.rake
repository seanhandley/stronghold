require 'json'

namespace :stronghold do
  desc "Perform SSL Labs Quality Check"
  task :ssl_quality_check => :environment do
    analysis = JSON.parse(Net::HTTP.get(URI("https://api.ssllabs.com/api/v2/analyze?host=my.datacentred.io&fromCache=on&maxAge=168")))
    grade    = analysis["endpoints"][0]["grade"]
    Notifications.notify!(:ssl_quality_check, "Rated my.datacentred.io as #{grade}.")
    puts grade
    exit 0
  end
end
