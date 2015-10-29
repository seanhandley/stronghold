class SendNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(key, message)
    Notifications.notify!(key, message)
  end
end