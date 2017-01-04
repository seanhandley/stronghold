require 'json'

namespace :stronghold do
  desc "Perform code quality analysis"
  task :code_quality_analysis => :environment do
    command_output = `rubycritic app lib -f json`
    matcher = /(.+)Score: \d+\.\d+$/
    json = matcher.match(command_output.split("\n")[-1].strip)[1]
    analysis = JSON.parse(json)
    c_and_below = analysis['analysed_modules'].reject{|m| ['A','B'].include?(m['rating'].upcase)}
    rated_modules = ['C', 'D', 'E', 'F'].inject({}) do |acc, r|
      acc[r] = c_and_below.select{|m| m['rating'].upcase == r}
      acc
    end
    results = rated_modules.collect do |k,v|
      v.count > 0 ? "#{v.count} modules rated #{k}" : nil
    end.compact
    if rated_modules.values.flatten.count > 0
      Notifications.notify!(:code_quality_analysis, "#{results.join('. ')}. Run rubycritic locally for more info.")
    else
      Notifications.notify!(:code_quality_analysis, "All modules are rated A & B :heart_eyes_cat:")
    end
    puts results.join('. ')
    exit 0
  end
end
