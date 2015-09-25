require 'json'

namespace :stronghold do
  desc "Perform code quality analysis"
  task :code_quality_analysis => :environment do
    analysis = JSON.parse `rubycritic app lib -f json`
    c_and_below = analysis['analysed_modules'].reject{|m| ['A','B'].include?(m['rating'].upcase)}
    rated_modules = ['C', 'D', 'E', 'F'].inject({}) do |acc, r|
      acc[r] = c_and_below.select{|m| m['rating'].upcase == r}
      acc
    end
    results = rated_modules.collect do |k,v|
      "#{v.count} modules rated #{k}"
    end
    if rated_modules.values.flatten.count > 0
      Notifications.notify(:code_quality_analysis, "#{results.join('. ')}. Run rubycritic locally for more info.")
    end
    puts results.join('. ')
    exit 0
  end
end
