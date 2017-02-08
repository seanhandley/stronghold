if Rails.env.production?
  error_text = File.read(File.expand_path(File.join(File.dirname(__FILE__), "../../public/500.html")))
  RACK_ATTACK_LOGGER = Rails.env.production? ? ::Logger.new("/var/log/rails/stronghold/rack_attack.log") : Rails.logger

  # Always allow requests from localhost
  # (blacklist & throttles are skipped)
  Rack::Attack.whitelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Throttle requests to 5 requests per second per ip
  Rack::Attack.throttle('req/ip', :limit => 12, :period => 1.second) do |req|
    # If the return value is truthy, the cache key for the return value
    # is incremented and compared with the limit. In this case:
    #   "rack::attack:#{Time.now.to_i/1.second}:req/ip:#{req.ip}"
    #
    # If falsy, the cache key is neither incremented nor checked.

    req.ip
  end

  Rack::Attack.throttle('api req/ip', :limit => 1000, :period => 1.minute) do |req|
    if req.path.start_with? '/api'
      req.env['HTTP_AUTHORIZATION']&.scan(/Token token="(.*):(.*)"/)&.first&.first
    end
  end

  Rack::Attack.throttle('logins/email', :limit => 6, :period => 60.seconds) do |req|
    req.params.try(:[], 'user').try(:[],'email') if req.path == '/sessions' && req.post?
  end

  Rack::Attack.blacklisted_response = lambda do |env|
    # Using 503 because it may make attacker think that they have successfully
    # DOSed the site. Rack::Attack returns 403 for blacklists by default
    [ 503, {}, [error_text]]
  end

  Rack::Attack.throttled_response = lambda do |env|
    if env['REQUEST_URI'].start_with? '/api'
      now = Time.now
      match_data = env['rack.attack.match_data']

      headers = {
        'X-RateLimit-Limit' => match_data[:limit].to_s,
        'X-RateLimit-Remaining' => '0',
        'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
      }

      [ 429, headers, ["Throttled\n"]]
    else
      [ 503, {}, [error_text]]
    end
  end

  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req|
    if [:throttle, :blacklist].include?(req.env['rack.attack.match_type'])
      keys = ["CONTENT_LENGTH", "PATH_INFO", "QUERY_STRING", "REMOTE_ADDR", "REMOTE_HOST", "REQUEST_METHOD", "REQUEST_URI",  "HTTP_CONNECTION", "HTTP_CACHE_CONTROL", "HTTP_ACCEPT", "HTTP_ORIGIN", "HTTP_UPGRADE_INSECURE_REQUESTS", "HTTP_USER_AGENT", "HTTP_REFERER", "HTTP_ACCEPT_ENCODING", "HTTP_ACCEPT_LANGUAGE", "HTTP_VERSION", "REQUEST_PATH", "ORIGINAL_FULLPATH", "rack.attack.throttle_data",  "rack.attack.matched", "rack.attack.match_discriminator", "rack.attack.match_type", "rack.attack.match_data"]
      RACK_ATTACK_LOGGER.info "IP: #{req.ip}. Action: #{req.env['rack.attack.match_type']}. Details: #{keys.inject({}) {|acc, k| acc[k] = req.env[k]; acc}.to_json}"
    end
  end
end