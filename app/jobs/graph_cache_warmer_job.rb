class GraphCacheWarmerJob < ActiveJob::Base
  queue_as :default

  def perform
    LiveCloudResources.refresh_caches
  end
end
