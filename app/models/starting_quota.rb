module StartingQuota
  class << self
    def [](key)
      settings[key]
    end

    private

    def settings
      @@settings ||= YAML.load_file("#{Rails.root}/config/starting_quota.yml")
    end
  end
end
