class RestartSlowQueueJob < ApplicationJob
  queue_as :slow

  def perform
    `restart sidekiq_stronghold_slow`
  end
end
