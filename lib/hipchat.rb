require 'hipchat'

class Hipchat
  def self.notify(from, room, message)
    if HIPCHAT_NOTIFICATIONS_ENABLED
      client[room].send(from, message, :notify => true)  
    end
  end

  private

  def self.client
    HipChat::Client.new(Rails.application.secrets.hipchat_api_token)
  end
end
