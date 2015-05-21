class ActivationReminderJob < ActiveJob::Base
  queue_as :default

  def perform
    CustomerSignup.not_reminded.each do |cs|
      next if cs.created_at.utc < Time.now.utc + 1.hour
      next unless cs.organization
      next unless cs.organization.users.count > 0

      Mailer.activation_reminder(cs.email).deliver_later

      cs.update_attributes(reminder_sent: true)
    end
  end
end