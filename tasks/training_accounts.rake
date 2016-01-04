require 'csv'

namespace :stronghold do
  desc "Generate training accounts"
  task :training_accounts => :environment do
    if ENV['COUNT'].blank? || ENV['EMAIL_DOMAIN'].blank? || ENV['PROJECT_NAME'].blank?
      puts 'Usage: rake stronghold:training_accounts COUNT=1 EMAIL_DOMAIN="something.com" PROJECT_NAME="something" > accounts.csv'
      exit
    end
    count, email_domain, project_name = ENV['COUNT'].to_i, ENV['EMAIL_DOMAIN'], ENV['PROJECT_NAME']
    
    tag = TrainingAccountGenerator.new count: count, email_domain: email_domain, project_name: project_name
    
    tag.generate!

    csv = CSV.generate do |csv|
      csv << ['Username', 'Password', 'Project']
      tag.accounts.each {|account| csv << [account[:username], account[:password], account[:project]]}
    end
    puts csv
  end
end
