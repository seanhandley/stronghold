module Trackable
  def seen_online!(request)
    agent = UserAgent.parse(request.headers["HTTP_USER_AGENT"])
    info = {
      platform: agent.platform,
      os: agent.os,
      browser: agent.browser,
      version: agent.version,
      ip: request.remote_ip,
      url: request.url
    }
    Rails.cache.write("user_online_#{id}", info, expires_in: 5.minutes)
  end

  def online?
    !!last_known_connection
  end

  def last_known_connection
    Rails.cache.read("user_online_#{id}")
  end
end