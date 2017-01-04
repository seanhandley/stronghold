require 'sirportly'

args = YAML.load_file("#{Rails.root}/config/sirportly.yml")[Rails.env]

SIRPORTLY_BRAND  = args['brand'].downcase
domain = args['domain']
token = Rails.application.secrets.sirportly_token
secret = Rails.application.secrets.sirportly_secret

Sirportly.domain = domain
SIRPORTLY_CLIENT = Sirportly::Client.new(token, secret)

class SirportlyWrapper
  def method_missing(m, *args, &block)  
    SIRPORTLY_CLIENT.send(m, *args, &block)
  rescue Net::OpenTimeout => e
    raise Sirportly::Error, e.message
  end
end

SIRPORTLY = SirportlyWrapper.new