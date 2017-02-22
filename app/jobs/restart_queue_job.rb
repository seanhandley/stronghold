class RestartQueueJob < ApplicationJob
  queue_as :default

  def perform
    `sudo systemctl restart sidekiq_stronghold`
  end
end
