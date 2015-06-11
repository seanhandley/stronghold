settings = YAML.load_file("#{Rails.root}/config/slack.yml")[Rails.env]

SLACK_NOTIFICATIONS_ENABLED  = settings['enabled']
SLACK_NOTIFICATIONS_SETTINGS = settings['notifications']
