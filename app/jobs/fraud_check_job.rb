class FraudCheckJob < ActiveJob::Base
  queue_as :default

  def perform(customer_signup)
    fc = FraudCheck.new(customer_signup)
    if fc.suspicious?
      customer_signup.organization.hard_freeze!
      Mailer.fraud_check_alert(customer_signup, fc).deliver_later
      Mailer.review_mode_alert(customer_signup).deliver_later
    end
  end
end
