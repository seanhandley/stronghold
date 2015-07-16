module CephObject
  module Subclasses
    class User < Base
      def self.path ; '/admin/user?' ; end
    end
    class UserKey < Base
      def self.path ; '/admin/user?key&' ; end
    end
    class Usage < Base
      def self.path ; '/admin/bucket?' ; end
    end
    class UserQuota < Base
      def self.path; '/admin/user?quota&' ; end
    end
  end
end