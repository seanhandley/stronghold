require 'test_helper'

class Support::UsersControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    @user2 = User.make!(organizations: [@user.primary_organization])
    @organization = @user.primary_organization
    @organization.update_attributes(self_service: false)
    @admin_role = @organization.roles.make!(power_user: true)
    @member_role = @organization.roles.make!
    log_in(@user)
  end

  test "user can view profile" do
    get :index
    assert_response :success
    assert assigns(:user)
    assert_template "support/users/profile"
  end

  test "user can update own profile" do
    patch :update, params: { id: @user.id, user: {first_name: 'Foo'}}, format: 'js'
    assert_response :success
    assert @response.body.include? "saved"
  end

  test "user can't update with short password" do
    patch :update, params: { id: @user.id, user: {first_name: 'Foo', password: '1'}}, format: 'js'
    assert_response :unprocessable_entity
    assert @response.body.include? "too short"
  end

  test "reauthenticates with password change" do
    @controller.stub(:reauthenticate, true) do
      patch :update, params: { id: @user.id, user: {password: '87654321'}}, format: 'js'
      assert_response :ok
      assert @response.body.include? "saved"
    end
  end

  test "user can't delete users without permission" do
    delete :destroy, params: { id: @user2.id}, format: 'js'
    assert_response 302
    assert @response.body.include? support_root_path
  end

  test "user can delete another user if they have permission" do
    @user.update_attributes(roles: [@admin_role])
    delete :destroy, params: { id: @user2.id}, format: 'js'
    assert_response 302
    assert @response.body.include? support_roles_path
  end

  test "user can't delete self" do
    @user.update_attributes(roles: [@admin_role])
    delete :destroy, params: {id: @user.id}, format: 'js'
    assert_response :unprocessable_entity
    assert @response.body.include? "remove yourself"
  end

  test "user will only be deleted from current organization" do
    @user.update_attributes(roles: [@admin_role])
    @organization2 = Organization.make!(users: [@user2])
    assert @user2.organizations.include?(@organization)
    assert @user2.organizations.include?(@organization2)
    delete :destroy, params: { id: @user2.id}, format: 'js'
    assert_response 302
    @user2.reload
    refute @user2.organizations.include?(@organization)
    assert @user2.organizations.include?(@organization2)
  end

  test "user projects and roles will be removed once it leaves an organization" do
    @user.update_attributes(roles: [@admin_role])

    @organization2 = Organization.make!(users: [@user2])
    @project = Project.make!(organization_id: @organization2)
    # @user2.update_attributes(roles: [@member_role])

    UserProjectRole.create(user_id: @user2.id,
                           project_id: @project.id,
                           role_uuid: @member_role.uuid)

    assert UserProjectRole.find_by(user_id: @user2.id, project_id: @project.id, role_uuid: @member_role.uuid)
    assert @user2.projects.include?(@project)
    # assert @project.users.include?(@user2)
    # assert RoleUser.find_by(role_id: @member_role.id, user_id: @user2.id)
    # assert @member_role.users.include?(@user2)
    delete :destroy, params: { id: @user2.id}, format: 'js'
    assert_response 302
    @user2.reload
    refute @project.users.include?(@user2)
    refute UserProjectRole.find_by(user_id: @user2.id, project_id: @project.id, role_uuid: @member_role.uuid)
    # refute @member_role.users.include?(@user2)
    # refute RoleUser.find_by(role_id: @member_role.id, user_id: @user2.id)
  end
end
