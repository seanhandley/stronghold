$live_cloud_resources_job_mutex = Mutex.new

class LiveCloudResourcesJob < ActiveJob::Base
  queue_as :default

  def perform
    return if $live_cloud_resources_job_mutex.locked?
    $live_cloud_resources_job_mutex.synchronize do
      LiveCloudResources.refresh_caches
    end
  end
end
