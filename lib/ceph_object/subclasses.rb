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
      def self.get(params)
        super params.merge('quota-type' => 'user')
      end
      # Ceph::UserQuota.create 'uid' => '...', 'size' => 12345
      def self.create(params)
        body = {'enabled' =>true, 'max_size_kb' => params['size'], 'max_objects' => -1}
        super params.merge('quota-type' => 'user'), body.to_json
      end
    end
  end
end