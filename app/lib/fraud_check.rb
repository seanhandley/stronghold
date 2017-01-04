class FraudCheck
  attr_reader :customer_signup

  def initialize(customer_signup)
    @customer_signup = customer_signup
  end

  def request_fields
    signup_fields = {
      :client_ip => customer_signup.real_ip, 
      :forwarded_ip => customer_signup.forwarded_ip,
      :email => customer_signup.email,
      :user_agent => customer_signup.user_agent,
      :accept_language => customer_signup.accept_language
    }
    if customer_signup.organization
      org_fields = {
        :city => customer_signup.organization.billing_city, 
        :postal => customer_signup.organization.billing_postcode, 
        :country => customer_signup.organization.billing_country, 
        :shipping_address => [customer_signup.organization.billing_address1, customer_signup.organization.billing_address2].join("\n"),
        :shipping_city => customer_signup.organization.billing_city, 
        :shipping_postal => customer_signup.organization.billing_postcode, 
        :shipping_country => customer_signup.organization.billing_country, 
      }
      signup_fields.merge!(org_fields)
    end
    signup_fields
  end

  def card_fields
    return {} unless customer_signup.stripe_customer
    card = customer_signup.stripe_customer.sources.data.first
    {
      number: "*** *** *** #{card.last4}",
      kind: card.brand,
      fund: card.funding,
      country: Country.find_country_by_alpha2(card.country).to_s,
      expiry: "#{card.exp_month}/#{card.exp_year}",
      stripe_link: "https://dashboard.stripe.com/customers/#{card.customer}",
      cvc_check: card.cvc_check,
      address_check: card.address_line1_check,
      zip_check: card.address_zip_check
    }
  end

  def response_fields
    response.attributes
  end

  def suspicious?(force_new_response = false)
    Rails.cache.delete("fraud_check_#{customer_signup.id}") if force_new_response
    reasons = {
      "Risk score greater than five"         => -> { response_fields[:risk_score] > 5 },
      "Customer using a prepaid card"        => -> { customer_signup.prepaid? },
      "No CVC check on customer card"        => -> { customer_signup.no_cvc? },
      "More than 3 signups on this device"   => -> { customer_signup.other_signups_from_device > 3 },
      "More than 5 activation attempts"      => -> { customer_signup.activation_attempts > 5 }
     }
    reasons = reasons.select{|_,v| v.call}.map{|k,_| k}
    reasons.any? ? reasons : false
  end

  private

  def response
    Rails.cache.fetch("fraud_check_#{customer_signup.id}", expires_in: 30.days) do
      request = Maxmind::Request.new(request_fields)
      request.process!
    end
  end
end
