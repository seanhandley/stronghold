namespace :stronghold do
  desc "Sync an organization with Ceph REFERENCE=reference"
  task :ubuntu_usage => :environment do
    if ENV['MONTH'].blank? || ENV['YEAR'].blank?
      puts 'Usage: rake stronghold:ubuntu_usage MONTH=2 YEAR=2015'
      exit
    end
    month, year = ENV['MONTH'], ENV['YEAR']
    m = Time.parse("#{year}-#{month}-01 00:00:00 UTC")
    start_date, end_date = m, m.end_of_month
    usage = Billing::Instances.usage(nil, start_date, end_date)
    usage = usage.select{|u| u[:image][:name].downcase.include?('ubuntu')}.group_by{|u| u[:image][:name]}.collect do |name, results|
      [name, {hours_per_month: (results.collect{|r| r[:billable_hours]}.sum).ceil, arch: results.first[:arch]}]
    end
    puts CSV.generate {|csv| csv << ['Name', 'Hours Per Month', 'Arch']; Hash[usage].each{|k,v| csv << [k, *v.values]}}
  end
end
