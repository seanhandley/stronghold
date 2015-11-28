require 'test_helper'

class Support::ProjectsControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    @organization = @user.organization
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

  def assert_404(actions)
    actions.each do |verb, action, args|
      assert_raises(ActionController::RoutingError) do
        send verb, action, args
      end
    end
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

  test "Can create new tenant with good params" do
  end

  test "Can't create new tenant with bad params" do
  end

  test "Can update tenant with good params" do
  end

  test "Can't update tenant with bad params" do
  end

  test "Can destroy if not primary tenant" do
  end

  test "Can't destroy if primary tenant" do
  end

  def teardown
    DatabaseCleaner.clean
  end
end
