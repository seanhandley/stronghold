require 'sirportly'

settings = YAML.load_file("#{Rails.root}/config/sirportly.yml")[Rails.env]

domain = settings['domain']
token = Rails.application.secrets.sirportly_token
secret = Rails.application.secrets.sirportly_secret

Sirportly.domain = domain
SIRPORTLY = Sirportly::Client.new(token, secret)