require 'test_helper'

class TestOrganizationUser < CleanTest
  def setup
    @organization = Organization.make!
    @organization2 = Organization.make!
    @user = User.make!(organizations: [])
    OrganizationUser.create(user: @user, organization: @organization)
  end

  def test_new_users_organization_is_primary
    association = OrganizationUser.find_by user_id: @user.id, organization_id: @organization.id
    assert association.primary
  end

  def test_user_can_be_added_to_a_second_organization
    OrganizationUser.create(organization_id: @organization2.id, user_id: @user.id)
    assert 2, @user.organizations.count
  end

  def test_user_can_be_removed_from_an_organization
    OrganizationUser.create(organization_id: @organization2.id, user_id: @user.id)
    association2 = OrganizationUser.find_by user_id: @user.id, organization_id: @organization2.id
    assert 2, @user.organizations.count
    association2.destroy!
    assert 1, @user.organizations.count
  end

  def test_user_cant_be_removed_from_primary_organization
    old_count = @user.organizations.count
    association = OrganizationUser.find_by user_id: @user.id, organization_id: @organization.id
    assert ActiveRecord::RecordNotDestroyed do
      association.destroy
    end
    assert old_count, @user.organizations.count
  end

  def test_user_is_removed_if_no_remaining_organizations_associated
    relation = OrganizationUser.find_by(user_id: @user.id, organization_id: @organization.id)
    relation.destroy
    assert_raises ActiveRecord::RecordNotFound do
      @user.reload
    end
  end


end
