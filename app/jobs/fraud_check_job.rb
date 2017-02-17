class FraudCheckJob < ApplicationJob
  queue_as :default

  def perform(customer_signup)
    if Rails.env.production?
      fc = FraudCheck.new(customer_signup)
      return unless customer_signup.real_ip
      if fc.suspicious?
        customer_signup.organization.transition_to! :frozen
        Mailer.fraud_check_alert(customer_signup, fc).deliver_now_by_api
      end
    end
  end
end
