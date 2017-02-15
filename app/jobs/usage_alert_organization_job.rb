class UsageAlertOrganizationJob < ActiveJob::Base
  queue_as :default

  def perform(organization)
    organization = OrganizationUsageDecorator.new(organization)
    Mailer.quota_limits_alert(organization.id).deliver_now_by_api if organization.over_threshold?
  end
end
