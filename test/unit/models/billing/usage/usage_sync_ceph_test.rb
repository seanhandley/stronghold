require 'test_helper'

class TestUsageSyncCeph < CleanTest
  def setup
    @blob = {
      complex: {foo: 'bar'}
    }
    # This needs hardcoding for VCR
    @uuid = '3a6a220de-9a92-4320-803a-5fa95492386'
  end

  def test_random_uuid_on_create
    assert_equal 'foo', Billing::Usage.make!(object_uuid: 'foo').object_uuid
    refute_empty Billing::Usage.make!.object_uuid
  end

  def test_blob_create_update_and_delete_syncs_to_ceph
    VCR.use_cassette('usage_blob_syncs_to_ceph', :match_requests_on => [:path]) do

      # Test create
      @usage = Billing::Usage.make!(object_uuid: @uuid, blob: @blob)
      object_uuid = @usage.object_uuid

      assert_equal 'bar', @usage.blob[:complex][:foo]
      assert_equal 'bar', manually_retrieve_object('stronghold_usage', object_uuid)[:complex][:foo]

      # Test update
      @usage.blob = {something: 'else'}
      assert_equal 'else', @usage.blob[:something]
      assert_equal 'else', manually_retrieve_object('stronghold_usage', object_uuid)[:something]

      # Test destroy
      @usage.destroy

      assert_raises(OpenURI::HTTPError) do
        manually_retrieve_object('stronghold_usage', object_uuid)
      end
    end
  end

  private

  def manually_retrieve_object(bucket, object_uuid)
    AWS::S3::Base.establish_connection!(
      :server            => CEPH_ARGS[:api_url],
      :use_ssl           => true,
      :access_key_id     => CEPH_ARGS[:ceph_token],
      :secret_access_key => CEPH_ARGS[:ceph_key]
    )
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
  end
end
