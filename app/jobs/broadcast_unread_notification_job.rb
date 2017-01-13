class BroadcastUnreadNotificationJob < ApplicationJob
  def perform(ticket, update)
    from_user    = User.find_by email: update['from_address']
    organization = Organization.find_by reporting_code: ticket['contact']['reference'].split[0]
    updates      = SIRPORTLY.request("ticket_updates/all", ticket: ticket['reference'])
    users        = updates.map{|u| u['author']['reference'].split[2].gsub(')','').to_i}.uniq.map{|id| User.find_by_id(id)}.compact
    users.reject!{|u| u.id == from_user.id}
    users.reject!{|u| u.staff? } unless organization.staff?
    users.each do |user|
      UnreadTicket.create ticket_id: ticket['reference'],
                          update_id: update['id'],
                          user_id:   user.id
    end
  end
end