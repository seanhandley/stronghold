Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false
  end

  config.cache_store = :memory_store

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Mailer configuration
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      :address        => ENV["MAIL_SERVER_ADDRESS"],
      :domain         => ENV["MAIL_SERVER_DOMAIN"],
      :port           => ENV["MAIL_SERVER_PORT"],
      :authentication => ENV["MAIL_SERVER_AUTH_TYPE"]&.downcase&.to_sym,
      :user_name      => ENV["MAIL_SERVER_USERNAME"],
      :password       => ENV["MAIL_SERVER_PASSWORD"]
  }

  if File.directory?('/vagrant/')
    config.action_mailer.default_url_options = { :host => 'stronghold.vagrant.devel:8080' }
    config.action_controller.asset_host = 'stronghold.vagrant.devel:8080'
  else
    config.action_mailer.default_url_options = { :host => 'localhost:3000' }
    config.action_controller.asset_host = 'localhost:3000'
  end

  config.stripe.secret_key = ENV["STRIPE_SECRET_KEY"] || ""

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
