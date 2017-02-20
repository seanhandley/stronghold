class ActivationReminderJob < ApplicationJob
  queue_as :default

  def perform
    CustomerSignup.not_reminded.each do |cs|
      next unless (cs.created_at.utc + 1.hour) < Time.now.utc
      next unless cs.organization
      next unless cs.organization.users.count > 0

      unless cs.organization.known_to_payment_gateway?
        Mailer.activation_reminder(cs.email).deliver_now
      end

      cs.update_attributes(reminder_sent: true)
    end
  end
end