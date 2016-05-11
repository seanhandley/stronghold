module AntiFraud
  TEST_CHARGE_AMOUNT = 100

  def self.test_charge_succeeds?(organization)
    customer_id = organization.stripe_customer_id
    return [false, "Organization #{organization.id} has no stripe id associated."] unless customer_id

    charge = Stripe::Charge.create amount:      TEST_CHARGE_AMOUNT,
                                   currency:    "gbp",
                                   customer:    customer_id,
                                   description: "Test charge for #{customer_id}"

    Stripe::Refund.create charge: charge.id

    [true, 'Test charge succeeded.']
  rescue Stripe::StripeError => exception
    [false, exception.message]
  end
end
