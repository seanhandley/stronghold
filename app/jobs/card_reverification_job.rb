class CardReverificationJob < ActiveJob::Base
  queue_as :default

  def perform
    Organization.all.select(&:has_payment_method?).each do |organization|
      Stripe::Customer.retrieve(organization.stripe_customer_id).sources.each do |card|
        begin
          card.metadata[:last_verified] = Time.now.utc
          card.save
        rescue Stripe::CardError => e
          Mailer.card_reverification_failure(organization, card).deliver_now
          next
        end
      end
    end
  end
end