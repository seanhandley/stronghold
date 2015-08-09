class CardReverificationJob < ActiveJob::Base
  include StripeHelper
  queue_as :default

  def perform
    Organization.active.select(&:self_service?).select(&:known_to_payment_gateway?).each do |organization|
      begin
        unless stripe_has_valid_source?(organization.stripe_customer_id)
          organization.has_payment_methods!(false)
          Mailer.card_reverification_failure(organization).deliver_now
          Notifications.notify(:account_alert, "#{organization.name} (ref: #{organization.reference}) failed payment reverification. Please investigate ASAP and determine further action. The customer has been notified by email.")
        end
      rescue StandardError => e
        Honeybadger.notify(e)
        next
      end
    end
  end
end