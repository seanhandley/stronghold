require_relative '../../lib/fraud_record'

settings = YAML.load_file("#{Rails.root}/config/fraudrecord.yml")[Rails.env]

FRAUD_RECORD_ARGS = {
  :host    => settings['url']
}