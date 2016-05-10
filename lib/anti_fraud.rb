module AntiFraud
  TEST_CHARGE_AMOUNT = 100

  def self.test_charge_succeeds?(organization)
    customer_id = organization.stripe_customer_id

    charge = Stripe::Charge.create amount:      TEST_CHARGE_AMOUNT,
                                   currency:    "gbp",
                                   customer:    customer_id,
                                   description: "Test charge for #{customer_id}"

    refund = Stripe::Refund.create charge: charge.id

    if [charge, refund].all?{|e| e.status == 'succeeded'}
      [true, 'Test charge succeeded.']
    else
      [false, charge.status == 'succeeded' ? refund.status : charge.status]
    end
  end
end
