class StatusIOCacheWarmJob < ApplicationJob
  queue_as :default

  def perform
    Rails.cache.delete("status_io_active_incidents")
    StatusIO.active_incidents
    Rails.cache.delete("status_io_active_maintenances")
    StatusIO.active_maintenances
    Rails.cache.delete("status_io_upcoming_maintenances")
    StatusIO.upcoming_maintenances
  end
end
