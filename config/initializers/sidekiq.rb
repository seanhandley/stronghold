Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new {|ex,_| Honeybadger.notify(ex) }
  config.redis = { :namespace => 'stronghold' }
end

Sidekiq.configure_client do |config|
 config.redis = { :namespace => 'stronghold' }
end
