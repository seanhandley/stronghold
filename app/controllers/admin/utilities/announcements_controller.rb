module Admin
  module Utilities
    class AnnouncementsController < UtilitiesBaseController
      include StarburstHelper

      def index
        @active    = Starburst::Announcement.active.non_individual.map{|a| AnnouncementDecorator.new(a)}
        @scheduled = Starburst::Announcement.scheduled.non_individual.map{|a| AnnouncementDecorator.new(a)}
      end

      def create
        @announcement = Starburst::Announcement.new(starburst_params(create_params))
        if @announcement.save
          redirect_to admin_utilities_announcements_path, notice: 'Announcement created successfully'
        else
          flash[:error] = @announcement.errors.full_messages.join('<br>')
          respond_to do |format|
            format.html {
              render :index
            }
          end
        end
      end

      def destroy
        announcement = Starburst::Announcement.find(params[:id])
        announcement.stop_delivering_at = Time.now
        if announcement.save
          redirect_to admin_utilities_announcements_path, notice: "Successfully deactivated."
        else
          flash[:error] = @announcement.errors.full_messages.join('<br>')
          respond_to do |format|
            format.html {
              render :index
            }
          end
        end
      end

      def create_params
       params.permit(:title, :body, :start_delivering_at_date, :start_delivering_at_time, :stop_delivering_at_date, :stop_delivering_at_time, :filters => [:admin?, :colo?, :compute?, :storage?])
      end

    end
  end
end
