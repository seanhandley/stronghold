Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = true

  # Compress JavaScripts and CSS.
  config.assets.css_compressor = :sass
  # Prevent Angular conflicts
  config.assets.js_compressor = Uglifier.new(mangle: false)

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.1'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = false # This is handled in NginX

  # Set to :debug to see everything in the log.
  config.log_level = :info
  config.logger = ::Logger.new("/var/log/rails/stronghold/production.log")
  config.log_tags = [ :uuid ]

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  config.cache_store = :dalli_store, 'queue.datacentred.io:11211', {value_max_bytes: 1024 * 1024 * 10}

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  # Action Cable endpoint configuration
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "stronghold_#{Rails.env}"

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Mailer configuration
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      :address => 'smtp.mailgun.org',
      :domain => 'datacentred.co.uk',
      :port => 587,
      :user_name => ENV["MAIL_SERVER_USERNAME"],
      :password => ENV["MAIL_SERVER_PASSWORD"]
  }

  APP_DOMAIN = "https://my.datacentred.io"
  config.action_controller.asset_host = "https://assets-cdn.datacentred.io"
  config.action_mailer.asset_host = config.action_controller.asset_host
  config.action_mailer.default_url_options = { :host => APP_DOMAIN }

  # Error handling
  config.exceptions_app = self.routes

  config.stripe.publishable_key = "pk_live_vzTCZElYj4BdVeSj5648NROM"

  # Rack Attack
  config.middleware.use Rack::Attack

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_cable.allowed_request_origins = ["http://my.datacentred.io", "https://my.datacentred.io", "http://assets-cdn.datacentred.io", "https://assets-cdn.datacentred.io"]

end
