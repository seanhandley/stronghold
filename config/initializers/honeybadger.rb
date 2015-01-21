require 'sinatra'
require 'cancancan'

Honeybadger.configure do |config|
  config.api_key = '5a3dcd9f'
  config.ignore << Sinatra::NotFound
  config.ignore << CanCan::AccessDenied
end
