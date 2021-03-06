module Starburst
  class AnnouncementsController < ::ApplicationController

    def mark_as_read
      announcement = Announcement.find(params[:id].to_i)
      if respond_to?(Starburst.current_user_method) && send(Starburst.current_user_method) && announcement
        if AnnouncementView.where(user_id: send(Starburst.current_user_method).id, announcement_id: announcement.id).first_or_create(user_id: send(Starburst.current_user_method).id, announcement_id: announcement.id)
          render :json => :ok
        else
          render json: nil, :status => :unprocessable_entity
        end
      else
          Rails.logger.error "*" * 10
          Rails.logger.error "Bar"
          Rails.logger.error announcement.inspect
          Rails.logger.error respond_to?(Starburst.current_user_method)
          Rails.logger.error send(Starburst.current_user_method)
          render json: nil, :status => :unprocessable_entity
      end
    end
  end
end
