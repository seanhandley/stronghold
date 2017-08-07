require 'test_helper'

class TestApiCredential < CleanTest
  def setup
    @organization       = Organization.make!
    @organization2      = Organization.make!
    @user               = User.make!(organizations: [@organization, @organization2])
    @organization_user  = OrganizationUser.find_by(user: @user, organization: @organization)
    @organization_user2 = OrganizationUser.find_by(user: @user, organization: @organization2)

    ApiCredential.create!(password: SecureRandom.hex, organization_user: @organization_user)
    ApiCredential.create!(password: SecureRandom.hex, organization_user: @organization_user2)
  end

  def test_api_credentials_are_removed_when_user_leaves_organization
    assert_equal 2, ApiCredential.all.count
    @user.organization_users.where(organization: @organization2).destroy_all
    assert_equal 1, ApiCredential.all.count
    assert_equal @organization_user, ApiCredential.first.organization_user
  end
end
