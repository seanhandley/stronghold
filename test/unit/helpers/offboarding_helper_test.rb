require 'test_helper'
require_relative '../../../fixtures/mocks/offboarding_fixtures'

class TestModelNoUuid
  include OffboardingHelper

  def destroy
    offboard self
  end
end

class TestModel < TestModelNoUuid
  def uuid
    "12345"
  end
end

class OffboardingHelperTest < Minitest::Test
  include OffboardingFixtures

  def setup
    @model = TestModel.new
  end

  def model_destroy
    Fog::Compute.stub(:new, compute_mock) do
      Fog::Network.stub(:new, network_mock) do
        Fog::Volume.stub(:new, volume_mock) do
          assert @model.destroy
        end
      end
    end
  end

  def test_helper_checks_containing_model_has_uuid
    refute TestModelNoUuid.new.destroy
  end

  def test_only_instances_on_this_tenant_are_destroyed
    # Proved by mock expectations - see offboarding fixtures
    model_destroy
  end

  def test_routers_deleted
    # Proved by mock expectations - see offboarding fixtures
    model_destroy
  end

  def test_subnets_deleted
    # Proved by mock expectations - see offboarding fixtures
    model_destroy
  end

  def test_ports_deleted
    # Proved by mock expectations - see offboarding fixtures
    model_destroy
  end

  def test_networks_deleted
    # Proved by mock expectations - see offboarding fixtures
    model_destroy
  end

end
