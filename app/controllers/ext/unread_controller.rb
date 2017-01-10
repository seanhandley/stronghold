module Ext
  class UnreadController < ActionController::Base
    def create
      Rails.logger.info '*' * 10
      ticket       = JSON.parse create_params[:ticket]
      update       = JSON.parse create_params[:update]
      organization = Organization.find_by reference: ticket['contact']['reference'].split[0]
      from_user    = User.find_by email: update['from_address']
      Rails.logger.info "#{organization.name}: #{from_user.name}"
      Rails.logger.info '*' * 10
    end

    private

    def create_params
      params.permit(:ticket, :update)
    end
  end
end
