require 'ostruct'

class StripeController < ApplicationController
  protect_from_forgery :except => :webhook

  def webhook

    if params["type"] == "invoice.payment_succeeded"
      customer = Stripe::Customer.retrieve(params['data']['object']['customer']) rescue OpenStruct.new(description: "unknown")
      total = (params["data"]["object"]["total"] / 100.0).round(2)
      total = "%.2f" % (total)
      Notifications.notify(:new_signup, "Customer invoiced for £#{total}. #{customer.description}.")
    end

    render status: 200, json: nil
  end
end
