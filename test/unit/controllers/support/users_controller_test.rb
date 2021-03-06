require 'test_helper'

class Support::UsersControllerTest < CleanControllerTest
  setup do
    @user = User.make!
    @user2 = User.make!(organizations: [@user.primary_organization])
    @organization = @user.primary_organization
    @organization.update_attributes(self_service: false)
    @admin_role = @organization.roles.make!(power_user: true)
    @organization_user = OrganizationUser.find_by(organization_id: @organization.id, user_id: @user.id)
    log_in(@user)
    Authorization.current_user = @user
    Authorization.current_organization = @organization
    Authorization.current_organization_user = @organization_user
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
    @admin_role.update_attributes(organization_users: [@organization_user])
    delete :destroy, params: { id: @user2.id}, format: 'js'
    assert_response 302
    assert @response.body.include? support_roles_path
  end

  test "user can't delete self" do
    @admin_role.update_attributes(organization_users: [@organization_user])
    delete :destroy, params: {id: @user.id}, format: 'js'
    assert_response :unprocessable_entity
    assert @response.body.include? "remove yourself"
  end

end