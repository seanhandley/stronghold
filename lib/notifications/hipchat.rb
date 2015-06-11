require 'hipchat'

module Notifications
  class Hipchat
    def self.notify(key, message)
      if HIPCHAT_NOTIFICATIONS_ENABLED
        client[settings[key]['room']].send(settings[key]['from'], message, {:notify => true}.merge(settings[key]['format'].symbolize_keys!))  
      end
    end

    def self.settings
      HIPCHAT_NOTIFICATIONS_SETTINGS.dup
    end

    private

    def self.client
      HipChat::Client.new(Rails.application.secrets.hipchat_api_token)
    end
  end
end