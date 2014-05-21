require 'test_helper'

class TestRolePermissions < Minitest::Test
  def setup
    @role = Role.make!
  end

  def test_valid_by_default
    assert @role.valid?
  end

  def test_role_with_no_permissions_can_do_nothing
    @role.update_attributes(permissions: [])
    Permissions.user.each do |permission_name,_|
      refute @role.has_permission? permission_name
    end
  end

  def test_role_with_power_user_can_do_everything
    @role.update_attributes(power_user: true)
    Permissions.user.each do |permission_name,_|
      assert @role.has_permission? permission_name
    end   
  end

  def test_role_with_single_permission_allows_for_it_only
    sample_permission = Permissions.user.keys.sample
    @role.update_attributes(permissions: [sample_permission])
    Permissions.user.each do |permission_name,_|
      if permission_name == sample_permission
        assert @role.has_permission? permission_name
      else
        refute @role.has_permission? permission_name
      end
    end
  end

end