class StrongholdQueue
  attr_reader :settings

  def self.settings
    instance.settings
  end

  private

  def self.instance
    @@instance ||= new
  end

  def initialize
    redis_settings = YAML.load_file("#{Rails.root}/config/queue.yml")[Rails.env]
    redis_settings.symbolize_keys!
    redis_password = Rails.application.secrets.redis_password
    redis_settings.merge! redis_password.blank? ? {} : {password: redis_password}
    @settings = redis_settings
  end
end
