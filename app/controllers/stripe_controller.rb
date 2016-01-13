require 'ostruct'

class StripeController < ApplicationController
  protect_from_forgery :except => :webhook

  def webhook

    case params["type"]
    when "invoice.payment_succeeded"
      Notifications.notify(:stripe_success, "Invoice #{stripe_info[:invoice_id]}: Customer successfully billed or £#{stripe_info[:total]}. #{strip_info[:customer_description]}.")
    when params["type"] == "invoice.payment_failed"
      Notifications.notify(:stripe_fail, "Invoice #{stripe_info[:invoice_id]}: Payment of £#{stripe_info[:total]} for #{strip_info[:customer_description]} has failed.")
    end

    render status: 200, json: nil
  end

  def stripe_info
    @stripe_info ||= do
      customer = Stripe::Customer.retrieve(params['data']['object']['customer']) rescue OpenStruct.new(description: "unknown")
      total = (params["data"]["object"]["total"] / 100.0).round(2)
      total = "%.2f" % (total)
      {customer_description: customer.description, total: total, invoice_id: params["data"]["object"]["id"]}
    end
  end
end
