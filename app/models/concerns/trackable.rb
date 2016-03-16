module Trackable
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::DateHelper

  def self.included(base)
    base.class_eval do
      def self.online
        all.select(&:online_today?).sort do |x,y|
          y.last_known_connection[:timestamp] <=> x.last_known_connection[:timestamp]
        end
      end
    end
  end

  def seen_online!(request)
    agent = UserAgent.parse(request.headers["HTTP_USER_AGENT"])
    country = GeoIp.geolocation(request.remote_ip) rescue OpenStruct.new(country_code: 'GB', country_name: "United Kingdom")
    info = {
      platform: agent.platform,
      os: agent.os,
      browser: agent.browser,
      version: agent.version,
      ip: request.remote_ip,
      url: request.url,
      timestamp: Time.now,
      country: country[:country_code].downcase,
      country_name: country[:country_name]
    }
    Rails.cache.fetch("last_seen_online_#{id}", expires_in: 5.minutes) do
      Authorization.current_user&.update_attributes last_seen_online: Time.now
    end
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
