require 'test_helper'
require_relative '../../../fixtures/mocks/offboarding_fixtures'

class TestModel
  def uuid
    "12345"
  end
end

class OffboardingHelperTest < CleanTest
  include OffboardingFixtures
  include OffboardingHelper

  def setup
    @model = TestModel.new
  end

  def model_destroy
    OpenStackConnection.stub(:compute, compute_mock) do
      OpenStackConnection.stub(:network, network_mock) do
        OpenStackConnection.stub(:volume, volume_mock) do
          assert offboard TestModel.new, {}
        end
      end
    end
  end

  def test_only_instances_on_this_project_are_destroyed
    # Proved by mock expectations - see offboarding fixtures
  end

  def test_volumes_deleted
    # Proved by mock expectations - see offboarding fixtures
  end

  def test_snapshots_deleted
    # Proved by mock expectations - see offboarding fixtures
  end

  def test_images_deleted
    # Proved by mock expectations - see offboarding fixtures
  end

  def test_routers_deleted
    # Proved by mock expectations - see offboarding fixtures
  end

  def test_subnets_deleted
    # Proved by mock expectations - see offboarding fixtures
  end

  def test_ports_deleted
    # Proved by mock expectations - see offboarding fixtures
  end

  def test_networks_deleted
    # Proved by mock expectations - see offboarding fixtures
  end

  def test_with_auto_retry
    @retries = 0
    @mock = Minitest::Mock.new
    @mock.expect :ping, true
    assert(with_auto_retry(3) do
      @mock.ping
    end)
    @mock.verify

    @retries = 0
    Honeybadger.stub(:notify, true) do
      with_auto_retry(3,0) do
        @retries += 1
        raise Fog::Errors::Error, 'foo'
      end
    end
    assert_equal 3, @retries
  end

  def test_destroy_passes_expectations
    model_destroy
  end

end
