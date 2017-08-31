class BroadcastUnreadNotificationJob < ApplicationJob
  def perform(ticket, update)
    from_user    = User.find_by email: update['from_address']
    organization = Organization.find_by reporting_code: ticket['contact']['reference'].split[0] if ticket['contact']['reference']
    updates      = SIRPORTLY.request("ticket_updates/all", ticket: ticket['reference'])
    users        = updates.map{|u| p u; u['from_address']}.uniq.map{|email| User.find_by_email(email)}.compact
    users.reject!{|u| u.id == from_user.id} if from_user
    users.reject!{|u| u.staff? } unless organization && organization.staff?
    users.each do |user|
      UnreadTicket.create ticket_id: ticket['reference'],
                          update_id: update['id'],
                          organization_user: OrganizationUser.find_by(organization: organization, user: user)
    end
  end
end