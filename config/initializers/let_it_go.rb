if defined?(LetItGo::Middleware::Olaf) && ENV['LET_IT_GO']
  Rails.application.config.middleware.insert(0, LetItGo::Middleware::Olaf)
end