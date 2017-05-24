class UsageAlertOrganizationJob < ActiveJob::Base
  queue_as :default

  def perform(organization)
    organization = OrganizationUsageDecorator.new(organization)
    if organization.over_threshold? && organization.alerted_more_than_90_days_ago?
      Mailer.quota_limits_alert(organization.id).deliver_now
      organization.touch(:last_alerted_for_low_quotas_at)
    end
  end
end
