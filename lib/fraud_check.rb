module FraudCheck
  def self.looks_suspicious?(customer_signup)
    fields = {
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
      fields.merge!(org_fields)
    end
    request = Maxmind::Request.new(fields)
    response = request.process!
    # response.attributes = {:distance=>90, :country_match=>true, :country_code=>"DE", :free_mail=>false,
    #   :anonymous_proxy=>false, :bin_match=>"NA", :bin_country=>nil, :error=>nil, :proxy_score=>0.0,
    #   :ip_region=>2, :ip_city=>"Miltenberg", :ip_latitude=>49.7036, :ip_longitude=>9.2606, :bin_name=>nil,
    #   :ip_isp=>"Deutsche Telekom AG", :ip_org=>"Deutsche Telekom AG", :bin_name_match=>"NA",
    #   :bin_phone_match=>"NA", :bin_phone=>nil, :phone_in_billing_location=>nil, :high_risk_country=>false,
    #   :queries_remaining=>1097, :city_postal_match=>nil, :ship_city_postal_match=>nil,
    #   :maxmind_id=>"NJ1OEY1O", :ip_asnum=>"AS3320 Deutsche Telekom AG", :ip_user_type=>"residential",
    #   :ip_country_conf=>99, :ip_region_conf=>82, :ip_city_conf=>23, :ip_postal_code=>63897,
    #   :ip_postal_conf=>23, :ip_accuracy_radius=>39, :ip_net_speed_cell=>"Cable/DSL", :ip_metro_code=>0,
    #   :ip_area_code=>0, :ip_time_zone=>"Europe/Berlin", :ip_region_name=>"Bayern",
    #   :ip_domain=>"t-ipconnect.de", :ip_country_name=>"Germany", :ip_continent_code=>"EU",
    #   :ip_corporate_proxy=>false, :is_transparent_proxy=>false, :high_risk_email=>false,
    #   :ship_forward=>"NA", :risk_score=>0.1, :prepaid=>nil, :minfraud_version=>1.3,
    #   :service_level=>"standard"}
  end
end


