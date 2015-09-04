# Be sure to restart your server when you modify this file.
keys = {:expire_after => 1.hour, :key => '_stronghold_session'}
if defined?(APP_DOMAIN)
  keys.merge!(domain: APP_DOMAIN)
end

Rails.application.config.session_store ActionDispatch::Session::MemCacheStore, keys
