# Be sure to restart your server when you modify this file.

APP_DOMAIN = 'localhost' unless defined?(APP_DOMAIN)

Rails.application.config.session_store ActionDispatch::Session::MemCacheStore, :expire_after => 1.hour, :key => '_stronghold_session', domain: APP_DOMAIN
