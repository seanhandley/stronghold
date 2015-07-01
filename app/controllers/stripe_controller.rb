class StripeController < ApplicationController
  protect_from_forgery :except => :webhook

  def webhook

    if params["type"] == "invoice.payment_succeeded"
      customer = Stripe::Customer.retrieve(params['data']['object']['customer'])
      Notifications.notify(:new_signup, "Customer invoiced for £#{params["data"]["object"]["total"]}. #{customer.description}.")
    end

    render status: 200, json: nil
  end
end
