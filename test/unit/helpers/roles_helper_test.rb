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
    @user2 = User.make!(organizations: [@user.primary_organization])
    @organization_user2 = OrganizationUser.find_by(organization: @user.primary_organization, user: @user2)
    @role = Role.make!(name: 'Special Powers', organization: @user.primary_organization)
    @organization_user = OrganizationUser.find_by(user: @user, organization: @user.primary_organization) #Do we want primary org or current org?
    @organization_user.roles << @role
    @organization_user.save
    current_organization = @user.primary_organization
  end

  def test_list_of_roles
    assert_equal 'Special Powers', @model.list_of_roles(@organization_user)
  end

  def test_roles_for_select
    assert_equal "<option value=\"#{@role.id}\">Special Powers</option>", @model.roles_for_select(@user.primary_organization)
  end

  def test_organization_users_for_select
    assert_equal "<option value=\"#{@organization_user2.id}\">#{ERB::Util.html_escape(@user2.name + ' (' + @user2.email + ')' )}</option>", @model.organization_users_for_select(@role)
  end

  def test_projects_for_select
    project = @user.primary_organization.primary_project
    assert_equal "<option value=\"#{project.id}\">#{project.name}</option>", @model.projects_for_select(@user.primary_organization)
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

end
