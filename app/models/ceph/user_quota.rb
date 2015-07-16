module Ceph
  class UserQuota < CephObject::UserQuota
    LIMITED_QUOTA_SIZE_KB = 1000 ** 3 * 5 # 5GB
    def self.set_limited(uid)
      set_quota(uid, 'enabled' => true, 'max_size_kb' => LIMITED_QUOTA_SIZE_KB, 'max_objects' => -1)
    end

    def self.set_unlimited(uid)
      set_quota(uid, 'enabled' => false, 'max_size_kb' => -1, 'max_objects' => -1)
    end

    def self.get(uid)
      super default_params.merge('uid' => uid)
    end

    private

    def self.set_quota(uid, body)
      CephObject::UserQuota.create(default_params.merge('uid' => uid), body.to_json)
    end

    def self.default_params
      {'quota-type' => 'user'}
    end
  end
end