module Ext
  class UnreadController < ActionController::Base
    def create
      ticket       = JSON.parse create_params[:ticket]
      update       = JSON.parse create_params[:update]      
      from_user    = User.find_by email: update['from_address']
      updates      = SIRPORTLY.request("ticket_updates/all", ticket: ticket['reference'])
      users        = updates.map{|u| u['author']['reference'].split[2].gsub(')','').to_i}.uniq.map{|id| User.find_by_id(id)}.compact
      users.reject!{|u| u.id == from_user.id }
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
