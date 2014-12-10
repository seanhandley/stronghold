module CephObject
  module Subclasses
    class User < Base
      def self.path ; '/admin/user?' ; end
    end
    class UserKey < Base
      def self.path ; '/admin/user?key&' ; end
    end
  end
end