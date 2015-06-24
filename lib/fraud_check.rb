class FraudCheck

  def initialize(customer_signup)
    @customer_signup = customer_signup
  end

  def fields
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
      signup_fields.merge(org_fields)
    end
  end

  def looks_suspicious?(customer_signup)
    request = Maxmind::Request.new(fields)
    response = request.process!
    if response.attributes[:risk_score] > 5
      return response.attributes
    else
      return false
    end
  end
end


