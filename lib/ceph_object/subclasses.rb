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
      def self.get(params)
        request(:get, path, params)
      end
    end
  end
end