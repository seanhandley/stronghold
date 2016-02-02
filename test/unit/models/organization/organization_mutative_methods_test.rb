require 'test_helper'

class TestOrganizationMutativeMethods < CleanTest
  def setup
    @organization = Organization.make!
    @user = User.make!(organization: @organization)
  end

  def enable_or_disable(enable)
    Rails.env.stub(:test?, false) do
      mock = Minitest::Mock.new
      mock.expect(:update_project, nil, [@organization.primary_project.uuid, enabled: enable])
      mock.expect(:update_user, nil, [@user.uuid, enabled: enable])

      OpenStackConnection.stub(:identity, mock) do
        yield
      end
      mock.verify
    end
  end

  def test_enable!
    enable_or_disable(true) do
      @organization.enable!
    end
    assert_equal OrganizationStates::Active, @organization.state
  end

  def test_disable!
    enable_or_disable(false) do
      @organization.disable!
    end
    assert @organization.disabled?
  end

  def test_manually_activate!
    skip
    # refute @organization.manually_activate!
    # @organization.update_attributes(state: OrganizationStates::Fresh)
    # assert @organization.manually_activate!
  end
end