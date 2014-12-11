Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new {|ex,_| Honeybadger.notify(ex) }
end