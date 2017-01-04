class BillingRunJob < ApplicationJob
  queue_as :default

  def perform
    target_month = Time.now - 1.month
    Billing.billing_run!(target_month.year, target_month.month)
  end
end