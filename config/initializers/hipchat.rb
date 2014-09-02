settings = YAML.load_file("#{Rails.root}/config/hipchat.yml")[Rails.env]

HIPCHAT_NOTIFICATIONS_ENABLED = settings['enabled']
