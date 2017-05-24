class UsageAlertOrganizationJob < ActiveJob::Base
  ALERT_INTERVAL = Time.now - 90.days
  queue_as :default

  def perform(organization)
    organization = OrganizationUsageDecorator.new(organization)
    if organization.over_threshold? && organization.last_alerted_for_low_quotas_at < ALERT_INTERVAL
      Mailer.quota_limits_alert(organization.id).deliver_now
      organization.touch(:last_alerted_for_low_quotas_at)
    end
  end
end
