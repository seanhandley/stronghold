class CardReverificationJob < ActiveJob::Base
  include StripeHelper
  queue_as :default

  def perform
    Organization.active.select(&:known_to_payment_gateway?).each do |organization|
      unless stripe_has_valid_source?(organization.stripe_customer_id)
        organization.has_payment_methods!(false)
        Mailer.card_reverification_failure(organization).deliver_now
        Hipchat.notify('Stronghold', 'Accounts', "#{organization.name} (ref: #{organization.reference}) failed payment reverification. Please investigate ASAP and determine further action. The customer has been notified by email.")
      end
    end
  end
end