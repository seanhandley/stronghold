module AntiFraud
  TEST_CHARGE_AMOUNT = 100

  def self.test_charge_succeeds?(organization)
    # Do a charge and a refund. If either fails, return the error.
    # return [true, 'success'] or [false, 'error message']
    customer_id = organization.stripe_customer_id

    charge = Stripe::Charge.create(
      :amount => TEST_CHARGE_AMOUNT,
      :currency => "gbp",
      :customer => customer_id,
      :description => "Test charge for #{customer_id}"
    )

    refund = Stripe::Refund.create(
      charge: charge.id
    )

    if charge.status == 'succeeded' && refund.status == 'succeeded'
      return true
    else
      return false
    end
  end
end
