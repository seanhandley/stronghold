require 'slack-notifier'

module Notifications
  class Slack
    def self.notify(key, message)
      key = key.to_s
      raise ArgumentError, "Unknown settings: #{key}" unless settings[key]
      if SLACK_NOTIFICATIONS_ENABLED
        attachment = {
          fallback: message,
          text: message,
          color: settings[key]['color']
        }
        client.ping '', channel: settings[key]['channel'], attachments: [attachment]
      end
    end

    def self.settings
      SLACK_NOTIFICATIONS_SETTINGS.dup
    end

    private

    def self.client
      ::Slack::Notifier.new Rails.application.secrets.slack_webhook
    end
  end
end
