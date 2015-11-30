require 'test_helper'

class Support::ProjectsControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    @organization = @user.organization
    @user2 = User.make!(organization: @organization)
    @organization.update_attributes self_service: false
    @organization.products << Product.make!(:compute)
    @organization.save!
    @role = Role.make!(organization: @organization, power_user: true)
    @user.update_attributes(roles: [@role])
    @controller_paths = [
      [:get, :index, nil],
      [:post, :create, {tenant: {name: 'Foo', users: []}}],
      [:patch, :update, {id: 1, tenant: {name: 'Foo', users: []}}],
      [:delete, :destroy, {id: 1}]
    ]
    log_in(@user)
  end
  
  test "Can't do anything unless power user" do
    @user.update_attributes(roles: [])
    assert_404(@controller_paths)
  end

  test "Can't do anything unless cloud user" do
    @controller.current_organization.stub(:cloud?, false) do
      assert_404(@controller_paths)
    end
  end

  test "Can't do anything if restricted account" do
    @controller.current_organization.stub(:limited_storage?, true) do
      assert_404(@controller_paths)
    end
  end

  test "lists existing tenants" do
    get :index
    assert assigns(:tenants)
    assert_template :index
  end

  test "Can create new tenant with just name" do
    post :create, tenant: { name: 'Foo'}, quota: {compute: {}, volume: {}, network: {}}, format: 'js'
    assert_response 302
    assert @response.body.include? support_projects_path
  end

  test "Can create new tenant with users" do
    UserTenantRole.stub(:required_role_ids, ["foo"]) do
      post :create, tenant: { name: 'Foo', users: {@user.id.to_s => true}}, quota: {compute: {}, volume: {}, network: {}}, format: 'js'
      assert_response 302
      assert_equal 1, UserTenantRole.all.count
      assert @response.body.include? support_projects_path
    end
  end

  test "Can create new tenant with quotas" do
    post :create, tenant: { name: 'Foo' }, quota: {compute: {"instances" => 1}, volume: {"gigabytes" => 10}, network: {"floatingip" => 1}}, format: 'js'
    assert_response 302
    assert @response.body.include? support_projects_path
  end

  test "Can't create new tenant with bad params" do
    post :create, tenant: { name: ''}, quota: {compute: {}, volume: {}, network: {}}, format: 'js'
    assert_response :unprocessable_entity
    assert @response.body.include? "too short"
    post :create, tenant: { name: 'foo', users: {'300' => true}}, quota: {compute: {}, volume: {}, network: {}}, format: 'js'
    assert_response 302
    assert_equal 0, UserTenantRole.all.count
  end

  test "Can update tenant with just name" do
    patch :update, id: @organization.primary_tenant.id, tenant: { name: 'Bar'}, quota: {compute: {}, volume: {}, network: {}}, format: 'js'
    assert_response 302
    assert @response.body.include? support_projects_path
  end

  test "Can update tenant with users and remove users" do
    UserTenantRole.stub(:required_role_ids, ["foo"]) do
      patch :update, id: @organization.primary_tenant.id, tenant: { name: 'Foo', users: {@user.id.to_s => true, @user2.id.to_s => true}}, quota: {compute: {}, volume: {}, network: {}}, format: 'js'
      assert_response 302
      assert_equal 2, UserTenantRole.all.count
      assert @response.body.include? support_projects_path
      patch :update, id: @organization.primary_tenant.id, tenant: { name: 'Foo', users: {@user2.id.to_s => true}}, quota: {compute: {}, volume: {}, network: {}}, format: 'js'
      assert_response 302
      assert_equal 1, UserTenantRole.all.count
      assert @response.body.include? support_projects_path
    end
  end

  test "Can update tenant with quotas" do
    patch :update, id: @organization.primary_tenant.id, tenant: { name: 'Foo' }, quota: {compute: {"instances" => 3}, volume: {"gigabytes" => 20}, network: {"floatingip" => 1}}, format: 'js'
    assert_response 302
    assert @response.body.include? support_projects_path
  end

  test "Can't update tenant with bad params" do
    patch :update, id: @organization.primary_tenant.id, tenant: { name: '' }, quota: {compute: {"instances" => 3}, volume: {"gigabytes" => 20}, network: {"floatingip" => 1}}, format: 'js'
    assert_response :unprocessable_entity
    assert @response.body.include? "too short"
  end

  test "Can destroy if not primary tenant" do
    mock = Minitest::Mock.new
    mock.expect(:destroy_unless_primary, true)
    Tenant.stub(:find, mock) do
      tenant = @organization.tenants.create name: 'Foo'
      delete :destroy, id: tenant.id
      assert_redirected_to support_projects_path
      assert flash[:notice].include? "success"
    end
    mock.verify
  end

  test "Can't destroy if primary tenant" do
    delete :destroy, id: @organization.primary_tenant.id
    assert_redirected_to support_projects_path
    assert flash[:alert].include? "Couldn't delete project"
  end

  def teardown
    DatabaseCleaner.clean
  end
end
