class FraudCheckJob < ActiveJob::Base
  queue_as :default

  def perform(customer_signup)
    unless Rails.env.test? || Rails.env.acceptance?
      fc = FraudCheck.new(customer_signup)
      return unless customer_signup.real_ip
      if fc.suspicious?
        customer_signup.organization.hard_freeze!
        Mailer.fraud_check_alert(customer_signup, fc).deliver_now
        Mailer.review_mode_alert(customer_signup).deliver_now
      end
    end
  end
end
