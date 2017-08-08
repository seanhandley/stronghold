require 'test_helper'

class TestOrganizationUserRoles < CleanTest
  def setup
    @organization            = Organization.make!
    @user                    = User.make!(organizations: [@organization])
    @organization_user       = OrganizationUser.find_by(organization: @organization, user: @user)
    @role                    = Role.make(organization: @organization)
    @role2                   = Role.make(organization: @organization)
    @organization_user.roles = [@role, @role2]

    Authorization.current_user              = @user
    Authorization.current_organization      = @organization
    Authorization.current_organization_user = @organization_user
  end

  def test_user_cannot_be_assigned_same_role_twice
    r = OrganizationUserRole.create(organization_user: @organization_user, role: @role)
    refute r.save
  end

  def test_user_cannot_remove_self_from_power_group
    @role.update_attributes(power_user: true)
    refute @role.users.first.destroy
  end

  def test_user_cannot_be_stripped_of_all_roles
    @role2.users.first.destroy
    refute @role.users.first.destroy
  end

  def test_role_cannot_be_assigned_to_a_user_belonging_to_a_different_organization
    organization2      = Organization.make!
    user2              = User.make!(organizations: [organization2])
    organization_user2 = OrganizationUser.find_by(organization: organization2, user: user2)

    our = OrganizationUserRole.create role: @role, organization_user: organization_user2
    refute our.save
  end

  def test_correct_roles_removed_when_user_is_removed_from_a_second_organization
    organization2            = Organization.make!
    @user.organizations      = [@organization, organization2]
    role3                    = Role.make(organization: organization2)
    organization_user        = OrganizationUser.find_by(organization: organization2, user: @user)

    organization_user.roles = [role3]

    assert_equal 3, @user.reload.roles.count

    @user.organizations = [@organization]
    assert_equal 2, @user.reload.roles.count
    refute @user.roles.include?(role3)
  end
end
