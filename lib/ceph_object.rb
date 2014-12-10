require_relative 'ceph_object/base'
require_relative 'ceph_object/subclasses'

module CephObject
  include Subclasses
end