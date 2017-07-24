require 'ostruct'
# This StripeController class is responsible for retrieve Stripe customer info.
class StripeController < ApplicationController
  protect_from_forgery :except => :webhook
  before_action :verify_secret

  def webhook
    case params["type"]
    when "invoice.payment_succeeded"
      Notifications.notify(:stripe_success, notification_message("successfully"))

    when "invoice.payment_failed"
      Notifications.notify(:stripe_fail, notification_message("could not be"))
    end

    render status: 200, json: nil
  end

  private

  def stripe_info
    customer = Stripe::Customer.retrieve(params['data']['object']['customer']) rescue OpenStruct.new(description: "unknown")
    total = (params["data"]["object"]["total"] / 100.0).round(2)
    total = "%.2f" % (total)
    {
      customer_description: customer.description,
      total: total, invoice_id: params["data"]["object"]["id"],
      link: "https://dashboard.stripe.com/invoices/#{params["data"]["object"]["id"]}"
    }
  end

  def verify_secret
    unless params['secret'] == Rails.application.secrets.stripe_webhook_secret
      render status: 401, json: nil
    end
  end

  def notification_message(status)
    "Invoice #{stripe_info[:invoice_id]} for £#{stripe_info[:total]} #{status} charged to #{stripe_info[:customer_description]} (#{stripe_info[:link]})."
  end
end
