require 'test_helper'

class Support::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = Organization.make!
    @user = User.make! organizations: [@organization]
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
      [:get,   support_edit_organization_url],
      [:patch, support_organization_url(@organization)],
      [:post,  reauthorise_url],
      [:post,  close_account_url]
    ])
  end

  test "users can't change different orgs" do
    assert_404([
      [:patch , support_organization_url(@organization2), params: {organization: {name: 'foo'}}, xhr: true]
    ])
  end

  test "user can edit their own org" do
    VCR.use_cassette('organization_with_graph_data') do
      get support_edit_organization_url
    end
    assert assigns(:organization)
    assert_template "support/organizations/organization"
    patch support_organization_url(@organization), params: {organization: {name: 'foo'}}, xhr: true
    assert response.body.include?('Saved')
  end

  test "User can reauthorise with right password" do
    @controller.stub(:reauthenticate, true, "UpperLower123") do
      post :reauthorise, params: { password: "UpperLower123"}, xhr: true
      assert json_response['success']
    end
  end

  test "User can't reauthorise with wrong password" do
    @controller.stub(:reauthenticate, false, "wrgon") do
      post :reauthorise, params: { password: "wrgon"}, xhr: true
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
