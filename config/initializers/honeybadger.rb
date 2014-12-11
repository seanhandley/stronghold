Honeybadger.configure do |config|
  config.api_key = '5a3dcd9f'
  config.ignore  << Sinatra::NotFound
end
