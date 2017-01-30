require 'test_helper'

class Support::ProjectsControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    @organization = @user.organization
    @user2 = User.make!(organizations: [@organization])
    @organization.update_attributes self_service: false
    @organization.products << Product.make!(:compute)
    @organization.save!
    @role = Role.make!(organization: @organization, power_user: true)
    @user.update_attributes(roles: [@role])
    @controller_paths = [
      [:get, :index, nil],
      [:post, :create, {params: { project: {name: 'Foo', users: []}}}],
      [:patch, :update, {params: { id: 1, project: {name: 'Foo', users: []}}}],
      [:delete, :destroy, {params: { id: 1}}]
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

  test "lists existing projects" do
    get :index
    assert assigns(:projects)
    assert_template :index
  end

  test "Can create new project with just name" do
    post :create, params: { project: { name: 'Foo'}, quota: {compute: {"instances" => 1}, volume: {}, network: {}}}, format: 'js'
    assert_response 302
    assert @response.body.include? support_projects_path
  end

  test "Can create new project with users" do
    UserProjectRole.stub(:required_role_ids, ["foo"]) do
      post :create, params: { project: { name: 'Foo', users: {@user.id.to_s => true}}, quota: {compute: {"instances" => 1}, volume: {}, network: {}}}, format: 'js'
      assert_response 302
      assert_equal 1, UserProjectRole.all.count
      assert @response.body.include? support_projects_path
    end
  end

  test "Can create new project with quotas" do
    post :create, params: { project: { name: 'Foo' }, quota: {compute: {"instances" => 1}, volume: {"gigabytes" => 10}, network: {"floatingip" => 1}}}, format: 'js'
    assert_response 302
    assert @response.body.include? support_projects_path
  end

  test "Can't create new project with bad params" do
    post :create, params: { project: { name: ''}, quota: {compute: {"instances" => 1}, volume: {}, network: {}}}, format: 'js'
    assert_response :unprocessable_entity
    assert @response.body.include? "too short"
    post :create, params: { project: { name: 'foo', users: {'300' => true}}, quota: {compute: {"instances" => 1}, volume: {}, network: {}}}, format: 'js'
    assert_response 302
    assert_equal 0, UserProjectRole.all.count
  end

  test "Can update project with just name" do
    patch :update, params: { id: @organization.primary_project.id, project: { name: 'Bar'}, quota: {compute: {"instances" => 1}, volume: {}, network: {}}}, format: 'js'
    assert_response 302
    assert @response.body.include? support_projects_path
  end

  test "Can update project with users and remove users" do
    UserProjectRole.stub(:required_role_ids, ["foo"]) do
      patch :update, params: { id: @organization.primary_project.id, project: { name: 'Foo', users: {@user.id.to_s => true, @user2.id.to_s => true}}, quota: {compute: {"instances" => 1}, volume: {}, network: {}}}, format: 'js'
      assert_response 302
      assert_equal 2, UserProjectRole.all.count
      assert @response.body.include? support_projects_path
      patch :update, params: { id: @organization.primary_project.id, project: { name: 'Foo', users: {@user2.id.to_s => true}}, quota: {compute: {"instances" => 1}, volume: {}, network: {}}}, format: 'js'
      assert_response 302
      assert_equal 1, UserProjectRole.all.count
      assert @response.body.include? support_projects_path
    end
  end

  test "Can update project with quotas" do
    patch :update, params: { id: @organization.primary_project.id, project: { name: 'Foo' }, quota: {compute: {"instances" => 3}, volume: {"gigabytes" => 20}, network: {"floatingip" => 1}}}, format: 'js'
    assert_response 302
    assert @response.body.include? support_projects_path
  end

  test "Can't update project with bad params" do
    patch :update, params: { id: @organization.primary_project.id, project: { name: '' }, quota: {compute: {"instances" => 3}, volume: {"gigabytes" => 20}, network: {"floatingip" => 1}}}, format: 'js'
    assert_response :unprocessable_entity
    assert @response.body.include? "too short"
  end

  test "Can destroy if not primary project" do
    mock = Minitest::Mock.new
    mock.expect(:destroy_unless_primary, true)
    Project.stub(:find, mock) do
      project = @organization.projects.create name: 'Foo'
      delete :destroy, params: { id: project.id}
      assert_redirected_to support_projects_path
      assert flash[:notice].include? "success"
    end
    mock.verify
  end

  test "Can't destroy if primary project" do
    delete :destroy, params: { id: @organization.primary_project.id}
    assert_redirected_to support_projects_path
    assert flash[:alert].include? "Couldn't delete project"
  end

  def teardown
    DatabaseCleaner.clean
  end
end
