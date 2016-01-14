require 'ostruct'

class StripeController < ApplicationController
  protect_from_forgery :except => :webhook

  def webhook

    case params["type"]
    when "invoice.payment_succeeded"
      Notifications.notify(:stripe_success, "Invoice #{stripe_info[:invoice_id]} for £#{stripe_info[:total]} successfully charged to #{stripe_info[:customer_description]}.")
    when "invoice.payment_failed"
      Notifications.notify(:stripe_fail, "Invoice #{stripe_info[:invoice_id]} for £#{stripe_info[:total]} could not be charged to #{stripe_info[:customer_description]}.")
    end

    render status: 200, json: nil
  end

  private

  def stripe_info
    customer = Stripe::Customer.retrieve(params['data']['object']['customer']) rescue OpenStruct.new(description: "unknown")
    total = (params["data"]["object"]["total"] / 100.0).round(2)
    total = "%.2f" % (total)
    {customer_description: customer.description, total: total, invoice_id: params["data"]["object"]["id"]}
  end
end
