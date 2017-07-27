require 'test_helper'

class Support::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.make!
    @user2 = User.make!(organizations: [@user.primary_organization])
    @organization = @user.primary_organization
    @organization.update_attributes(self_service: false)
    @admin_role = @organization.roles.make!(power_user: true)
    log_in(@user)
  end

  test "user can view profile" do
    get support_profile_path
    assert_response :success
    assert assigns(:user)
    assert_template "support/users/profile"
  end

  test "user can update own profile" do
    patch support_user_path(@user), params: { user: {first_name: 'Foo'}}, xhr: true
    assert_response :success
    assert @response.body.include? "saved"
  end

  test "user can't update with short password" do
    patch support_user_path(@user), params: { user: {first_name: 'Foo', password: '1'}}, xhr: true
    assert_response :unprocessable_entity
    assert @response.body.include? "too short"
  end

  test "reauthenticates with password change" do
    patch support_user_path(@user), params: { user: {password: '87654321'}}, xhr: true
    assert_response :ok
    assert @response.body.include? "saved"
  end

  test "user can't delete users without permission" do
    @user.update_attributes(roles: [])
    delete support_user_path(@user2), xhr: true
    assert_response 302
    assert @response.body.include? support_root_path
  end

  test "user can delete another user if they have permission" do
    @user.update_attributes(roles: [@admin_role])
    delete support_user_path(@user2), xhr: true
    assert_response 302
    assert @response.body.include? support_roles_path
  end

  test "user can't delete self" do
    @user.update_attributes(roles: [@admin_role])
    delete support_user_path(@user), xhr: true
    assert_response :unprocessable_entity
    assert @response.body.include? "remove yourself"
  end

end