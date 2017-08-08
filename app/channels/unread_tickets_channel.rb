class UnreadTicketsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_organization_user
  end
end
