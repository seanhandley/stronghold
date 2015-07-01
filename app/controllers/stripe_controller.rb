class StripeController < ApplicationController
  protect_from_forgery :except => :webhook

  def webhook

    # invoice.payment_succeeded 
    Notifications.notify(:new_signup, "Stripe hook says: #{params.inspect}")

    render status: 200, json: nil
  end
end