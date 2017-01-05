# [532, 319, 321, 1014]
namespace :stronghold do
  desc "Rebuild usage data for Ceph"
  task :rebuild_usage_data => :environment do
    if ENV['IDS'].blank?
      puts 'Usage: rake stronghold:rebuild_usage_data IDS="1,2,3"'
      exit
    end
    ids = ENV['IDS'].split(',').map{|id| id.trim.to_i }

    orgs = ids.map{|id| Organization.find(id)}
    orgs.each do |org|
      oldest = Organization.first.created_at.year
      (oldest..Time.now.year).to_a.reverse.each do |year|
        (1..12).to_a.reverse.each do |month|
          next if Time.now.year == year && month > 1
          next if Time.parse("#{year}-#{month}-#{org.created_at.day}") < org.created_at.beginning_of_day
          UsageDecorator.new(org, year, month).usage_data
          puts "#{org.name}: #{year}-#{month}"
        end
      end
    end
  end
end
