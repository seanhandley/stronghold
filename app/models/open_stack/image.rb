module OpenStack
  class Image < OpenStackObject::Image
    attributes :name, :size
  end
end