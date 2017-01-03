class UsageAlertJob < ActiveJob::Base
  queue_as :default

  def perform
    Organization.active.each do |organization|
       UsageAlertOrganizationJob.perform_later(organization)
    end
  end
end
