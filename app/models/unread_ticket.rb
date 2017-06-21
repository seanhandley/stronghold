class UnreadTicket < ApplicationRecord
  belongs_to :user
  belongs_to :organization_user

  after_create  :update_unread_count
  after_destroy :update_unread_count

  private

  def update_unread_count
    UpdateUnreadTicketCountJob.perform_now(organization_user, self.destroyed?)
  end
end
