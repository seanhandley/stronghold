class UnreadTicket < ApplicationRecord
  belongs_to :user

  after_create  :update_unread_count
  after_destroy :update_unread_count

  private

  def update_unread_count
    UpdateUnreadTicketCountJob.perform_now(user)
  end
end
