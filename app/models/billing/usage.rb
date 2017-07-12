require 'open-uri'

module Billing
  class Usage < ApplicationRecord
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
      parse_timestamps(
        JSON.parse(
          open(
            AWS::S3::S3Object.url_for(
              object_uuid,
              bucket,
              authenticated: true
            )
          ).read,
          symbolize_names: true
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
        new_blob.to_json,
        bucket,
        content_type: 'application/json'
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
      conn
      AWS::S3::S3Object.delete(object_uuid, bucket)
    rescue StandardError => ex
      Honeybadger.notify(ex)
    end

    def bucket
      'stronghold_usage'
    end

    def parse_timestamps(enum)
      if enum.is_a?(Array)
        enum.each_with_index do |element, i|
          if element.is_a? String
            enum[i] = Time.parse(element) rescue element
          elsif element.is_a? Enumerable
            enum[i] = parse_timestamps(element)
          end
        end
      elsif enum.is_a?(Hash)
        enum.each do |k,v|
          if v.is_a? String
            enum[k] = Time.parse(v) rescue v
          elsif v.is_a? Enumerable
            enum[k] = parse_timestamps(v)
          end
        end
      end
      enum
    end
  end
end
