module Ext
  class UnreadController < ActionController::Base
    def create
      ticket       = JSON.parse create_params[:ticket]
      update       = JSON.parse create_params[:update]
      organization = Organization.find_by reporting_code: ticket['contact']['reference'].split[0]
      from_user    = User.find_by email: update['from_address']
      users        = organization.users.reject{|u| u.id == from_user.id}
      users.each do |user|
        UnreadTicket.create ticket_id: ticket['reference'],
                            update_id: update['id'],
                            user_id:   user.id
      end
      head :no_content
    end

    private

    def create_params
      params.permit(:ticket, :update)
    end
  end
end
