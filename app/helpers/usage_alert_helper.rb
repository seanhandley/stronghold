module UsageAlertHelper
  ALERT_FREQUENCY_THRESHOLD = 5.days

  def alerts_message(organization=current_organization)
    OrganizationUsageDecorator.new(organization).threshold_message
  end

  def send_quota_limits_alert_mail
    Rails.cache.fetch("quota_alert_email_sent_#{current_organization.id}", expires_in: ALERT_FREQUENCY_THRESHOLD) do
      Mailer.quota_limits_alert(current_organization).deliver_later
    end
  end
end
