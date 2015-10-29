require 'json'

namespace :stronghold do
  desc "Perform security analysis"
  task :security_analysis => :environment do
    analysis = JSON.parse `brakeman -q -f json`
    case analysis['scan_info']['security_warnings'].to_i
    when 0
      puts "No security issues found."
      exit 0
    else
      msg = "There are #{analysis['scan_info']['security_warnings']} potential security issues. Run brakeman locally for more info."
      Notifications.notify!(:security_analysis, msg)
      puts msg
      exit 1
    end
  end
end
