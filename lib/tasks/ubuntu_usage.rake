require 'csv'

namespace :stronghold do
  desc "Get Ubuntu Usage"
  task :ubuntu_usage => :environment do
    if ENV['MONTH'].blank? || ENV['YEAR'].blank?
      puts 'Usage: rake stronghold:ubuntu_usage MONTH=2 YEAR=2015'
      exit
    end
    month, year = ENV['MONTH'], ENV['YEAR']
    m = Time.parse("#{year}-#{month}-01 00:00:00 UTC")
    start_date, end_date = m, m.end_of_month
    usage = Billing::Instances.usage(nil, start_date, end_date)
    usage = usage.reject{|u| Project.find_by_uuid(u[:project_id]).organization.test_account? rescue true}
    usage = usage.select{|u| Project.find_by_uuid(u[:project_id]).organization.paying? rescue true}
    usage = usage.select{|u| u[:image][:name].downcase.include?('ubuntu')}.group_by{|u| u[:image][:name]}.collect do |name, results|
      [name, {hours_per_month: (results.collect{|r| r[:billable_hours]}.sum).ceil, arch: results.first[:arch]}]
    end
    puts CSV.generate {|csv| csv << ['Name', 'Hours Per Month', 'Arch']; Hash[usage].each{|k,v| csv << [k, *v.values]}}
  end

  desc "Get Ubuntu Usage Detailed"
  task :ubuntu_usage_detailed => :environment do
    if ENV['MONTH'].blank? || ENV['YEAR'].blank?
      puts 'Usage: rake stronghold:ubuntu_usage_detailed MONTH=2 YEAR=2015'
      exit
    end
    month, year = ENV['MONTH'], ENV['YEAR']
    m = Time.parse("#{year}-#{month}-01 00:00:00 UTC")
    start_date, end_date = m, m.end_of_month
    usage = Billing::Instances.usage(nil, start_date, end_date)
    usage = usage.reject{|u| Project.find_by_uuid(u[:project_id]).organization.test_account? rescue true}
    usage = usage.select{|u| Project.find_by_uuid(u[:project_id]).organization.paying? rescue true}
    usage = usage.select{|u| u[:image][:name].downcase.include?('ubuntu')}.collect do |r|
      [r[:image][:name], r[:billable_hours], r[:arch], r[:name], r[:project_id]]
    end
    puts CSV.generate {|csv| csv << ['Image Name', 'Billable Hours', 'Arch', 'Instance Name', 'Project']; usage.each{|u| csv << u}}
  end
end
