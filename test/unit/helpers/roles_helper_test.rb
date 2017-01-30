require 'test_helper'

class TestModel
  include ActionView::Helpers::FormOptionsHelper
  include RolesHelper

  def params ; end
end

class RolesHelperTest < CleanTest
  def setup
    @model = TestModel.new
    @user = User.make!
    @user2 = User.make!(organizations: [@user.organizations.first])
    @role = Role.make!(name: 'Special Powers', organization: @user.organizations.first)
    @user.roles << @role
    @user.save
  end

  def test_list_of_roles
    assert_equal 'Special Powers', @model.list_of_roles(@user)
  end

  def test_roles_for_select
    assert_equal "<option value=\"#{@role.id}\">Special Powers</option>", @model.roles_for_select(@user.organizations.first)
  end

  def test_users_for_select
    assert_equal "<option value=\"#{@user2.id}\">#{ERB::Util.html_escape(@user2.name)}</option>", @model.users_for_select(@role)
  end

  def test_projects_for_select
    project = @user.organizations.first.primary_project
    assert_equal "<option value=\"#{project.id}\">#{project.name}</option>", @model.projects_for_select(@user.organizations.first)
  end

  def test_active_tab
    @model.stub(:params, {tab: 'foo'}) do
      assert_equal '', @model.active_tab?('bar')
      assert_equal 'active', @model.active_tab?('foo')
    end

    @model.stub(:params, {}) do
      assert_equal '', @model.active_tab?('bar')
      assert_equal 'active', @model.active_tab?('users')
    end
  end

  def test_invite_status_label
    assert_equal "<span class=\"label label-default\"><i class=\"fa fa-envelope\"></i> PENDING</span>", @model.invite_status_label('pending')
    assert_equal "<span class=\"label label-success\"><i class=\"fa fa-envelope\"></i> DELIVERED</span>", @model.invite_status_label('delivered')
    assert_equal "<span class=\"label label-danger\"><i class=\"fa fa-envelope\"></i> UNDELIVERED</span> <p class='text-danger'><em>(Mail server responded: failed :-()</em></p>", @model.invite_status_label('failed :-(')
  end

end



