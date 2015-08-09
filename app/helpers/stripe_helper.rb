module StripeHelper
  def rescue_stripe_errors(handler, &blk)
    yield
  rescue Stripe::CardError => e
    handler.call e.message
  rescue Stripe::APIConnectionError
    notify_honeybadger(e)
    handler.call "Payment provider isn't responding. Please try again."
  rescue Stripe::StripeError => e
    notify_honeybadger(e)
    handler.call "We're sorry - something went wrong. Our tech team has been notified."
  end

  def stripe_has_valid_source?(stripe_customer_id)
    customer = Stripe::Customer.retrieve(stripe_customer_id)
    return false unless customer.respond_to?(:sources)
    sources = customer.sources.all(:object => "card")
    # Ensure at least one card is valid
    sources.each do |source|
      begin
        source.metadata[:last_verified] = Time.now.utc
        source.save
        return true
      rescue Stripe::CardError
        next
      end
    end
    false
  end
end