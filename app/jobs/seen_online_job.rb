class SeenOnlineJob < ActiveJob::Base
  queue_as :default

  def perform(info)
    Rails.cache.write("user_online_#{id}", info.merge(timestamp: Time.now), expires_in: 1.day)
  end
end