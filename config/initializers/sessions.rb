settings = YAML.load_file("#{Rails.root}/config/sessions.yml")[Rails.env]

SESSION_TIMEOUT = settings['timeout']
