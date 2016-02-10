class ClearStaleSignupsJob < ActiveJob::Base
  queue_as :default

  def perform
    Organization.pending_without_users.each do |organization|
      if organization.created_at < Time.now - 2.weeks
        begin
          organization.destroy
        rescue StandardError => e
          Honeybadger.notify(e)
          next
        end
      end
    end
  end
end