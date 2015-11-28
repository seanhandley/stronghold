require 'test_helper'

class Support::RolesControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    @organization = @user.organization
    @organization.update_attributes self_service: false
    @role = Role.make!(organization: @organization, power_user: true)
    @role2 = Role.make!(organization: @organization)
    @user.update_attributes(roles: [@role])
    log_in(@user)
  end

  test "index sets the necessary variables" do
    get :index
    assert assigns(:roles)
    assert assigns(:users)
    assert assigns(:open_invites)
    assert_template "support/roles/index"
  end

  test "can create new role" do
    post :create, role: {name: 'foo'}
    assert assigns(:role)
    assert @response.body.include? support_roles_path(tab: 'roles')
  end

  test "can rename role" do
    patch :update, id: @role.id, role: {name: 'bar'}, format: 'js'
    assert @response.body.include? support_roles_path(tab: 'roles')
  end

  test "can update existing role permissions" do
    patch :update, id: @role2.id, role: {name: @role2.name, permissions: ['access_requests.modify']}, format: 'js'
    refute @response.body.include? support_roles_path(tab: 'roles')
    assert_response :ok
  end

  test "can't destroy role if someone is assigned" do
    @user.roles << @role2
    @user.save!
    delete :destroy, id: @role2.id
    assert_redirected_to support_roles_path(tab: 'roles')
    assert flash[:notice].include? 'users assigned'
  end

  test "can't destroy role if it's the admin role" do
    delete :destroy, id: @role.id
    assert_redirected_to support_roles_path(tab: 'roles')
    assert flash[:notice].include? 'power user'
  end

  test "can destroy role if nobody is assigned" do
    delete :destroy, id: @role2.id
    assert_redirected_to support_roles_path(tab: 'roles')
    assert flash[:notice].include? 'success'
  end

  def teardown
    DatabaseCleaner.clean
  end
end