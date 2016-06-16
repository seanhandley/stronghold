class FraudCheckJob < ActiveJob::Base
  queue_as :default

  def perform(customer_signup)
    if Rails.env.production?
      fc = FraudCheck.new(customer_signup)
      return unless customer_signup.real_ip
      if fc.suspicious?
        customer_signup.organization.hard_freeze!
        Mailer.fraud_check_alert(customer_signup, fc).deliver_now
        Mailer.review_mode_alert(customer_signup.organization).deliver_now
      end
    end
  end
end
