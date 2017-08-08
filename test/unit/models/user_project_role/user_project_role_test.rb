require 'test_helper'

class TestUserProjectRoles < CleanTest
  def setup
    @organization  = Organization.make!
    @organization2 = Organization.make!
    @user          = User.make!(organizations: [@organization, @organization2])
    @project       = Project.make!(organization: @organization)
    @project2      = Project.make!(organization: @organization2)
    UserProjectRole.create(user: @user, project: @project,  role_uuid: 'foo')
    UserProjectRole.create(user: @user, project: @project2, role_uuid: 'foo')
  end

  def test_user_project_roles_are_removed_when_user_leaves_organization
    assert_equal 2, @user.projects.count
    @user.organization_users.where(organization: @organization2).destroy_all
    assert_equal 1, @user.reload.projects.count
  end
end
