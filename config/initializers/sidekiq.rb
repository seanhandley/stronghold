Sidekiq.default_worker_options = {
  unique: :until_and_while_executing,
  unique_args: ->(args) { [ args.first.except('job_id') ]},
  unique_job_expiration: 600
}

Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new {|ex,_| Honeybadger.notify(ex) }
  config.redis = { :namespace => 'stronghold' }
end

Sidekiq.configure_client do |config|
 config.redis = { :namespace => 'stronghold' }
end
