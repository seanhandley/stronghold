require 'test_helper'

class TestOrganizationMutativeMethods < CleanTest
  def setup
    @organization = Organization.make!
    @organization.transition_to(:active)
    @user = User.make!(organizations: [@organization])
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

  def test_disable!
    enable_or_disable(false) do
      @organization.transition_to(:disabled)
    end
    assert_equal 'disabled', @organization.current_state
  end

  def test_enable!
    enable_or_disable(false) do
      @organization.transition_to(:disabled)
    end
    enable_or_disable(true) do
      @organization.transition_to(:active)
    end
    assert_equal 'active', @organization.current_state
  end
end
