module FraudCheck
  def self.looks_suspicious?(customer_signup)
    fields = {
      :client_ip => customer_signup.real_ip, 
      :city => customer_signup.organization.billing_city, 
      :postal => customer_signup.organization.billing_postcode, 
      :country => customer_signup.organization.billing_country, 
      :forwarded_ip => customer_signup.forwarded_ip,
      :email => customer_signup.email,
      :shipping_address => [customer_signup.organization.address1, customer_signup.organization.address1].join("\n"),
      :shipping_city => customer_signup.organization.billing_city, 
      :shipping_postal => customer_signup.organization.billing_postcode, 
      :shipping_country => customer_signup.organization.billing_country, 
      :user_agent => customer_signup.user_agent,
      :accept_language => customer_signup.accept_language
    }
    request = Maxmind::Request.new(fields)
    response = request.process!
  end
end


