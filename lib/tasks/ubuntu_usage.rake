namespace :stronghold do
  desc "Sync an organization with Ceph REFERENCE=reference"
  task :ubuntu_usage => :environment do
    if ENV['QUARTER'].blank? || ENV['YEAR'].blank?
      puts 'Usage: rake stronghold:ubuntu_usage QUARTER=2 YEAR=2015'
      exit
    end
    quarter, year = ENV['QUARTER'], ENV['YEAR']
    start_date, end_date = nil, nil
    case quarter.upcase
    when '1'
      start_date, end_date = Time.parse("#{year}-01-01 00:00:00 UTC"), Time.parse("#{year}-04-01 00:00:00 UTC")
    when '2'
      start_date, end_date = Time.parse("#{year}-04-01 00:00:00 UTC"), Time.parse("#{year}-07-01 00:00:00 UTC")
    when '3'
      start_date, end_date = Time.parse("#{year}-07-01 00:00:00 UTC"), Time.parse("#{year}-10-01 00:00:00 UTC")
    when '4'
      start_date, end_date = Time.parse("#{year}-10-01 00:00:00 UTC"), Time.parse("#{year.to_i+1}-01-01 00:00:00 UTC")
    end
    usage = Billing::Instances.usage(nil, start_date, end_date)
    usage = usage.select{|u| u[:image][:name].downcase.include?('ubuntu')}.group_by{|u| u[:image][:name]}.collect do |name, results|
      [name, {hours_per_month: (results.collect{|r| r[:billable_hours]}.sum / 3.0).ceil, arch: results.first[:arch]}]
    end
    puts Hash[usage].inspect
  end
end
