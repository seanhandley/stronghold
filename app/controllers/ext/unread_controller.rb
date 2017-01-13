module Ext
  class UnreadController < ActionController::Base
    def create
      ticket       = JSON.parse create_params[:ticket]
      update       = JSON.parse create_params[:update]      
      BroadcastUnreadNotificationJob.perform_later(ticket, update)
      head :no_content
    end

    private

    def create_params
      params.permit(:ticket, :update)
    end
  end
end
