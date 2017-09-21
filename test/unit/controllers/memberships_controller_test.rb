require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase
  setup do
    @user = User.make! email: 'foo@bar.com'
    @organization = @user.primary_organization
    @role = @organization.roles.create name: 'foo'
    @invite = Invite.create! organization: @organization,
                         email: @user.email,
                         roles: [@role]
  end

  test "thanks path" do
    get :thanks, params: { organization_id: @invite.organization }
    assert_template :thanks
  end

  test "confirm path with valid token" do
    get :confirm, params: { token: @invite.token }
    assert_template :confirm
    assert_template layout: "layouts/customer-sign-up"
  end

  test "confirm path without valid token" do
    assert_raises ActionController::RoutingError do
      get :confirm, params: { token: 'foo' }
    end
  end

  test "create path successful" do
    mock = Minitest::Mock.new
    mock.expect :unscoped_token, 'blah'
    Fog::Identity.stub(:new, mock) do
      post :create, params: { token: @invite.token }
      assert session[:user_id]
      assert session[:created_at]
      # assert session[:token]
      assert_redirected_to membership_thanks_path(@invite.organization)
    end
  end

  test "create path unsuccessful" do
    @invite.update_attributes(completed_at: Time.now)
    post :create, params: { token: @invite.token }
    assert flash[:alert].length > 0
    assert_response :unprocessable_entity
    assert_template :confirm
    assert_template layout: "layouts/customer-sign-up"
  end
end
