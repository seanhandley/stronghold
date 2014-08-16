module OpenStack
  class Image < OpenStackObject::Image
    attributes :name, :size, :created_at, :updated_at, :progress,
               :status, :minDisk, :minRam, :server, :metadata
  end
end
