require 'hipchat'

class Hipchat
  def self.notify(room, message)
    if HIPCHAT_NOTIFICATIONS_ENABLED
      client[room].send('JIRA', message)  
    end
  end

  private

  def self.client
    HipChat::Client.new(Rails.application.secrets.hipchat_api_token)
  end
end
