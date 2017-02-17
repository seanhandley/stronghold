class DeliverInviteJob < ApplicationJob
  queue_as :default

  def perform(invite)
    message = Mailer.signup(invite.id).deliver_now_by_api
    invite.update_column :remote_message_id, message.id
  end
end