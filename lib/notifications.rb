Dir[File.join(File.dirname(__FILE__), 'notifications', '*.rb')].each {|file| require file }

module Notifications

  def self.notifiers
    Notifications.constants
  end

  def self.notify(settings, message)
    notifiers.each{|n| "Notifications::#{n.to_s}".constantize.send(:notify, *[settings, message])}
  end

end