class GraphCacheWarmerJob < ActiveJob::Base
  queue_as :default

  def perform
    OrganizationGraphDecorator.refresh_caches
  end
end
