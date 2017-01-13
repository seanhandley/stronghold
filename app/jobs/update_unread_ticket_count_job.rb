class UpdateUnreadTicketCountJob < ApplicationJob
  def perform(user)
    unread_count = user.unread_tickets.count
    UnreadTicketsChannel.broadcast_to(user, unread_count: unread_count, play_sounds: user.play_sounds?)
  end
end