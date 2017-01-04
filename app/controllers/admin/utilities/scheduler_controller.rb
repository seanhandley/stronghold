module Admin
  module Utilities
    class SchedulerController < UtilitiesBaseController
      include DaemonControlHelper

      def index ; end

      def restart
        restart_clockwork
        respond_to do |format|
          format.js {
            render :template => "shared/dialog_info", :locals => {:message => restart_message }
          }
        end
      end
    end
  end
end
