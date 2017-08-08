require 'test_helper'

class TestUserRoles < CleanTest
  def setup
    @user  = User.make
    @role  = Role.make
    @role2 = Role.make
    Authorization.current_user = @user
    @role_user  = RoleUser.create(user: @user, role: @role)
    @role_user2 = RoleUser.create(user: @user, role: @role2)
  end

  def test_user_cannot_be_assigned_same_role_twice
    r = RoleUser.create(user: @user, role: @role)
    refute r.save
  end

  def test_user_cannot_remove_self_from_power_group
    @role.update_attributes(power_user: true)
    refute @role_user.destroy
  end

  def test_user_cannot_be_stripped_of_all_roles
    @role_user.destroy
    refute @role_user2.destroy
  end
end