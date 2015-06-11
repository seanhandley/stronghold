Dir[File.join(File.dirname(__FILE__), 'notifications', '*.rb')].each {|file| require file }

module Notifications

  def self.notifiers
    Notifications.constants
  end

  def self.notify(key, message)
    key = key.to_s
    notifiers.each do |n|
      begin
        o = "Notifications::#{n.to_s}".constantize
        raise ArgumentError, "Unknown settings: #{key}" unless o.settings[key]
        m = "#{o.settings[key]['prefix']} #{message}" if o.settings[key]['prefix']
        o.send(:notify, *[key, m])
      rescue StandardError => e
        Honeybadger.notify(e)
      end
    end
  end

end