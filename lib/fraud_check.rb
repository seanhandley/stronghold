module FraudCheck
  def self.looks_suspicious?(customer_signup)
    fields = {
      :client_ip => '24.24.24.24', 
      :city => 'New York', 
      :postal => '11434', 
      :country => 'US',
      :forwarded_ip => '24.24.24.25',
      :email => 'test@test.com',
      :shipping_address => '145-50 157th Street',
      :shipping_city => 'Jamaica',
      :shipping_postal => '11434',
      :shipping_country => 'US',
      :user_agent => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_5; en-us) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.20.1',
      :accept_language => 'en-us'
    }
    request = Maxmind::Request.new(fields)
    response = request.process!
  end
end


