require 'test_helper'

class Support::RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.make!
    @organization = @user.primary_organization
    @organization.update_attributes self_service: false
    @role = Role.make!(organization: @organization, power_user: true)
    @role2 = Role.make!(organization: @organization)
    @user.update_attributes(roles: [@role])
    log_in(@user)
  end

  test "index sets the necessary variables" do
    get support_roles_url
    assert assigns(:roles)
    assert assigns(:users)
    assert assigns(:open_invites)
    assert_template "support/roles/index"
  end

  test "can create new role" do
    post support_roles_url, params: { role: {name: 'foo'}}, xhr: true
    assert assigns(:role)
    assert_response 302
    assert @response.body.include? support_roles_path(tab: 'roles')
  end

  test "can't create new role with bad params" do
    post support_roles_url, params: { role: {name: ''}}, xhr: true
    assert_response :unprocessable_entity
    assert @response.body.include? "Name is too short"
  end

  test "can rename role" do
    patch support_role_url(@role), params: { role: {name: 'bar'}}, xhr: true
    assert_response 302
    assert @response.body.include? support_roles_path(tab: 'roles')
  end

  test "can't rename role to be blank" do
    patch support_role_url(@role), params: { role: {name: ''}}, xhr: true
    assert_response :unprocessable_entity
    assert @response.body.include? "Name is too short"
  end

  test "can update existing role permissions" do
    patch support_role_url(@role2), params: { role: {name: @role2.name, permissions: ['roles.read']}}, xhr: true
    refute @response.body.include? support_roles_path(tab: 'roles')
    assert_response :ok
  end

  test "can't update existing role permissions with bad data" do
    patch support_role_url(@role2), params: { role: {name: @role2.name, permissions: ['grdfdggdf']}}, xhr: true
    assert_response :unprocessable_entity
  end

  test "can't destroy role if someone is assigned" do
    @user.roles << @role2
    @user.save!
    delete support_role_url(@role2)
    assert_redirected_to support_roles_path(tab: 'roles')
    assert flash[:notice].include? 'users assigned'
  end

  test "can't destroy role if it's the admin role" do
    delete support_role_url(@role)
    assert_redirected_to support_roles_path(tab: 'roles')
    assert flash[:notice].include? 'power user'
  end

  test "can destroy role if nobody is assigned" do
    delete support_role_url(@role2)
    assert_redirected_to support_roles_path(tab: 'roles')
    assert flash[:notice].include? 'success'
  end

  def teardown
    DatabaseCleaner.clean
  end
end