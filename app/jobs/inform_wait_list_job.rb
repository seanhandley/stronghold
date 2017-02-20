class InformWaitListJob < ApplicationJob
  queue_as :default

  def perform
    WaitListEntry.awaiting_email.each do |entry|
      Mailer.notify_wait_list_entry(entry.email).deliver_now
      entry.update_attributes(emailed_at: Time.now.utc)
    end
  end
end