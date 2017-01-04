require 'test_helper'

class Support::OrganizationsControllerTest < ActionController::TestCase
  setup do
    @organization = Organization.make!
    @user = User.make! organization: @organization
    @organization.update_attributes self_service: false
    @organization2 = Organization.make!
    @role = Role.make!(organization: @organization, power_user: true)
    @user.update_attributes(roles: [@role])
    [@organization, @organization2].each{|o| o.transition_to(:active)}
    log_in(@user)
  end

  test "only power users get to do anything org related" do
    @user.update_attributes(roles: [])
    assert_404([
      [:get, :index, nil],[:patch, :update, {params: { id: @organization.id}}],
      [:post, :reauthorise, {params: { id: @organization.id}}],[:post, :close, {params: { id: @organization.id}}]
    ])
  end

  test "users can't change different orgs" do
    assert_404([
      [:patch ,:update, params: {format: 'js', id: @organization2.id, organization: {name: 'foo'}}]
    ])
  end

  test "user can edit their own org" do
    VCR.use_cassette('organization_with_graph_data') do
      get :index
    end
    assert assigns(:organization)
    assert_template "support/organizations/organization"
    patch :update, params: {format: 'js', id: @organization.id, organization: {name: 'foo'}}
    assert response.body.include?('Saved')
  end

  test "User can reauthorise with right password" do
    @controller.stub(:reauthenticate, true, "UpperLower123") do
      post :reauthorise, params: { password: "UpperLower123"}, format: 'json'
      assert json_response['success']
    end
  end

  test "User can't reauthorise with wrong password" do
    @controller.stub(:reauthenticate, false, "wrgon") do
      post :reauthorise, params: { password: "wrgon"}, format: 'json'
      refute json_response['success']
    end
  end

  test "User can't close account with wrong password" do
    @controller.stub(:reauthenticate, false, "wrgon") do
      post :close, params: { password: "wrgon"}
      assert_redirected_to support_edit_organization_path
    end
  end

  test "User can close account with right password" do
    @controller.stub(:reauthenticate, true, "UpperLower123") do
      @controller.current_organization.stub(:transition_to!, true) do
        post :close, params: { password: "UpperLower123"}
        refute session[:user_id]
        refute session[:token]
        assert_template :goodbye
      end
    end
  end

  test "dc staff can't close account" do
    @organization.update_attributes(reference: 'datacentred')
    @controller.stub(:reauthenticate, true, "UpperLower123") do
      post :close, params: { password: "UpperLower123"}
      assert_redirected_to support_edit_organization_path
    end
  end

  def teardown
    DatabaseCleaner.clean
  end
end
