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
end