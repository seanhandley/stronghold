class SeenOnlineJob < ActiveJob::Base
  queue_as :default

  def perform(params)
    agent   = UserAgent.parse(params[:user_agent])
    country = GeoIp.geolocation(params[:remote_ip]) rescue OpenStruct.new(country_code: 'GB', country_name: "United Kingdom")
    user    = User.find(params[:user_id])
    info    = {
      platform: agent.platform,
      os: agent.os,
      browser: agent.browser,
      version: agent.version,
      ip: params[:remote_ip],
      url: params[:url],
      timestamp: Time.parse(params[:time]),
      country: country[:country_code].downcase,
      country_name: country[:country_name]
    }
    Rails.cache.fetch("last_seen_online_#{user.id}", expires_in: 5.minutes) do
      user&.update_attributes last_seen_online: Time.now
    end
    Rails.cache.write("user_online_#{id}", info, expires_in: 1.day)
  end
end