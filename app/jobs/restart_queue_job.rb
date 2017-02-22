class RestartQueueJob < ApplicationJob
  queue_as :slow

  def perform
    `sudo systemctl restart sidekiq_stronghold`
  end
end
