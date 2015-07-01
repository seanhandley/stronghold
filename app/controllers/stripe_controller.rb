class StripeController < ApplicationController
  protect_from_forgery :except => :webhook

  def webhook

    if params["type"] == "invoice.payment_succeeded"
      Notifications.notify(:new_signup, "Stripe hook says: #{params["data"]["object"]["total"]}")
      
    end

    render status: 200, json: nil
  end
end

# {"created"=>1326853478, "livemode"=>false, "id"=>"evt_00000000000000",
#   "type"=>"invoice.payment_succeeded", "object"=>"event", "request"=>nil,
#   "pending_webhooks"=>1, "api_version"=>"2015-02-18",
#   "data"=>{"object"=>{"date"=>1435756022, "id"=>"in_00000000000000",
#     "period_start"=>1435756022, "period_end"=>1435756022,
#     "lines"=>{"data"=>[{"id"=>"sub_6WoYotnzt2FsXl", "object"=>"line_item",
#       "type"=>"subscription", "livemode"=>true,
#       "amount"=>2000, "currency"=>"gbp", "proration"=>false,
#       "period"=>{"start"=>1438434422, "end"=>1441112822}, "subscription"=>nil,
#       "quantity"=>1, "plan"=>{"interval"=>"month", "name"=>"Gold Special",
#         "created"=>1435756022, "amount"=>2000, "currency"=>"gbp", "id"=>"gold",
#         "object"=>"plan", "livemode"=>false, "interval_count"=>1, "trial_period_days"=>nil,
#         "metadata"=>{}, "statement_descriptor"=>nil}, "description"=>nil, "discountable"=>true,
#         "metadata"=>{}}], "total_count"=>1, "object"=>"list",
#         "url"=>"/v1/invoices/in_16JkvaAR2MipIX2irTlzDSvX/lines"},
#         "subtotal"=>0, "total"=>0,
#         "customer"=>"cus_00000000000000",
#         "object"=>"invoice", "attempted"=>true, "closed"=>true, "forgiven"=>false,
#         "paid"=>true, "livemode"=>false, "attempt_count"=>0, "amount_due"=>0,
#         "currency"=>"gbp", "starting_balance"=>0, "ending_balance"=>nil,
#         "next_payment_attempt"=>1435759622,
#         "webhooks_delivered_at"=>nil,
#         "charge"=>"_00000000000000", "discount"=>nil, "application_fee"=>nil,
#         "subscription"=>nil, "tax_percent"=>nil, "tax"=>nil,
#         "metadata"=>{}, "statement_descriptor"=>nil, "description"=>nil,
#         "receipt_number"=>nil}}, "controller"=>"stripe", "action"=>"webhook",
#         "stripe"=>{"created"=>1326853478, "livemode"=>false,
#           "id"=>"evt_00000000000000", "type"=>"invoice.payment_succeeded", "object"=>"event", "request"=>nil, "pending_webhooks"=>1, "api_version"=>"2015-02-18", "data"=>{"object"=>{"date"=>1435756022, "id"=>"in_00000000000000", "period_start"=>1435756022, "period_end"=>1435756022, "lines"=>{"data"=>[{"id"=>"sub_6WoYotnzt2FsXl", "object"=>"line_item", "type"=>"subscription", "livemode"=>true, "amount"=>2000, "currency"=>"gbp", "proration"=>false, "period"=>{"start"=>1438434422, "end"=>1441112822}, "subscription"=>nil, "quantity"=>1, "plan"=>{"interval"=>"month", "name"=>"Gold Special", "created"=>1435756022, "amount"=>2000, "currency"=>"gbp", "id"=>"gold", "object"=>"plan", "livemode"=>false, "interval_count"=>1, "trial_period_days"=>nil, "metadata"=>{}, "statement_descriptor"=>nil}, "description"=>nil, "discountable"=>true, "metadata"=>{}}], "total_count"=>1, "object"=>"list", "url"=>"/v1/invoices/in_16JkvaAR2MipIX2irTlzDSvX/lines"}, "subtotal"=>0, "total"=>0, "customer"=>"cus_00000000000000", "object"=>"invoice", "attempted"=>true, "closed"=>true, "forgiven"=>false, "paid"=>true, "livemode"=>false, "attempt_count"=>0, "amount_due"=>0, "currency"=>"gbp", "starting_balance"=>0, "ending_balance"=>nil, "next_payment_attempt"=>1435759622, "webhooks_delivered_at"=>nil, "charge"=>"_00000000000000", "discount"=>nil, "application_fee"=>nil, "subscription"=>nil, "tax_percent"=>nil, "tax"=>nil, "metadata"=>{}, "statement_descriptor"=>nil, "description"=>nil, "receipt_number"=>nil}}}}