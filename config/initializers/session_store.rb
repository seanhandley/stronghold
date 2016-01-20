# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, {:key => '_stronghold_session', :domain => (defined?(APP_DOMAIN) ? APP_DOMAIN : 'localhost')}