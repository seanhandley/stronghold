class AnnouncementDecorator < ApplicationDecorator
  def pretty_filters
    limit_to_users ? limit_to_users.map{|filter| filter[:field].titleize.gsub('?','')}.join(", ") : 'All'
  end

  def percentage_viewed
    (announcement_views.count / User.count * 100)
  end

  def start_delivering_at
    model.start_delivering_at&.strftime(date_format) || '-'
  end

  def stop_delivering_at
    model.stop_delivering_at&.strftime(date_format) || '-'
  end

  private

  def date_format
    "%e %b %Y - %R %Z"
  end
end
