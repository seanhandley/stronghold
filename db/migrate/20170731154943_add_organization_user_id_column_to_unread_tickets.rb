class AddOrganizationUserIdColumnToUnreadTickets < ActiveRecord::Migration[5.0]
  def change
    add_column :unread_tickets, :organization_user_id, :integer

    # UnreadTicket.find_each do |unread_ticket|
    #   organization_user = OrganizationUser.find_by(user: unread_ticket.user, organization: unread_ticket&.user&.primary_organization)
    #   organization_user ? unread_ticket.update_attributes(organization_user: organization_user) : unread_ticket.destroy
    # end
  end
end
