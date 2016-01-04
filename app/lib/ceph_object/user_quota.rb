module CephObject
  class UserQuota < Base
    def self.path; '/admin/user?quota&' ; end
  end
end
