module Trackable
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::DateHelper

  def seen_online!(request)
    agent = UserAgent.parse(request.headers["HTTP_USER_AGENT"])
    info = {
      platform: agent.platform,
      os: agent.os,
      browser: agent.browser,
      version: agent.version,
      ip: request.remote_ip,
      url: request.url,
      timestamp: Time.now,
      country: GeoIp.geolocation(request.remote_ip)[:country_code]
    }
    Rails.cache.write("user_online_#{id}", info, expires_in: 1.day)
  end

  def online_today?
    !!last_known_connection
  end

  def online_now?
    online_today? && last_known_connection[:timestamp] > Time.now - 5.minutes
  end

  def status
    online_now? ? tag('i', class: ['fa', 'fa-circle'], style: 'color: green;') + " Online" : tag('i', class: ['fa', 'fa-circle'], style: 'color: grey;') + " Last seen #{time_ago_in_words last_known_connection[:timestamp]} ago"
  end

  def last_known_connection
    Rails.cache.read("user_online_#{id}")
  end

end