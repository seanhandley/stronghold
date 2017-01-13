module UserPreferences
  def self.included(base)
    base.class_eval do
      def self.default_preferences
        {'play_notification_sounds' => "1"}
      end

      serialize :preferences
      def preferences
        read_attribute(:preferences) || User.default_preferences.dup
      end
    end
  end

  def play_sounds?
    preferences["play_notification_sounds"] == "1"
  end
end
