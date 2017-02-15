require_relative "./stronghold_queue"

Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new {|ex,_| Honeybadger.notify(ex) }
  config.redis = StrongholdQueue.settings
end

Sidekiq.configure_client do |config|
 config.redis = StrongholdQueue.settings
end
