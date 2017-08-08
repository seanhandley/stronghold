class UpdateUnreadTicketCountJob < ApplicationJob
  def perform(organization_user, destroyed=false)
    return unless organization_user
    unread_count = organization_user.unread_tickets.count || 0
    UnreadTicketsChannel.broadcast_to(organization_user, unread_count: unread_count, increased: !destroyed, play_sounds: organization_user.user.play_sounds?)
  end
end