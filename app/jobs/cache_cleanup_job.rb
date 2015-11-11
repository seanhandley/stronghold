class CacheCleanupJob < ActiveJob::Base
  queue_as :default

  def perform
    Rails.cache.cleanup
  end
end