module Trackable
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::DateHelper

  def self.included(base)
    base.class_eval do
      def self.online
        all.select(&:online_today?).sort do |x,y|
          y.last_known_connection[:timestamp] <=> x.last_known_connection[:timestamp]
        end
      end
    end
  end

  def seen_online!(request)
    return true if online_now?
    SeenOnlineJob.perform_later({
      user_agent: request.headers["HTTP_USER_AGENT"],
      remote_ip:  request.remote_ip,
      user_id:    id,
      url:        request.url,
      time:       Time.now.to_s
    })
  end

  def online_today?
    !!last_known_connection
  end

  def online_now?
    online_today? && last_known_connection[:timestamp] > Time.now - 5.minutes
  end

  def status
    online_now? ? tag('i', class: ['fa', 'fa-circle'], style: 'color: green;') + " Online" : tag('i', class: ['fa', 'fa-circle'], style: 'color: grey;') + " Last seen #{time_ago_in_words last_known_connection[:timestamp]} ago"
  end

  def last_known_connection
    Rails.cache.read("user_online_#{id}")
  end

end
