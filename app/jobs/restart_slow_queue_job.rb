class RestartSlowQueueJob < ApplicationJob
  queue_as :slow

  def perform
    `sudo systemctl restart sidekiq_stronghold_slow`
  end
end
