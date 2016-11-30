require 'open-uri'

module Billing
  class Usage < ActiveRecord::Base
    self.table_name = "billing_usages"

    attr_accessor :blob

    belongs_to :organization
    before_destroy :remove_blob
    after_create -> { update_column :updated_at, Time.at(0) }

    def object_uuid
      if persisted?
        read_attribute(:object_uuid) || update_column(:object_uuid, SecureRandom.uuid)
      else
        read_attribute(:object_uuid) || write_attribute(:object_uuid, SecureRandom.uuid)
      end
      read_attribute(:object_uuid)
    end

    def object_uuid=(uuid)
      write_attribute(:object_uuid, uuid)
    end

    def blob
      conn
      Marshal.load(
        open(
          AWS::S3::S3Object.url_for(
            object_uuid,
            bucket,
            authenticated: true
          )
        )
      )
    rescue OpenURI::HTTPError => ex
      raise unless ex.message.include?("404")
      {}
    end

    def blob=(new_blob)
      conn
      AWS::S3::S3Object.store(
        object_uuid,
        Marshal.dump(new_blob),
        bucket,
        content_type: 'application/octet-stream'
      )
    end

    private

    def conn
      AWS::S3::Base.establish_connection!(
        :server            => CEPH_ARGS[:api_url],
        :use_ssl           => true,
        :access_key_id     => CEPH_ARGS[:ceph_token],
        :secret_access_key => CEPH_ARGS[:ceph_key]
      )
    end

    def remove_blob
      AWS::S3::S3Object.delete(object_uuid, bucket)
    rescue StandardError => ex
      Honeybadger.notify(ex)
    end

    def bucket
      'stronghold_usage'
    end
  end
end
