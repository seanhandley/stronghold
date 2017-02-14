require 'test_helper'

class SignupsControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    @organization = @user.organization
    @role = @organization.roles.create name: 'foo'
    @invite = Invite.create! organization: @organization,
                         email: 'foo@bar.com',
                         roles: [@role]
    Stronghold::SIGNUPS_ENABLED = true
  end

  test "new path redirects when logged in" do
    log_in(@user)
    get :new
    assert_redirected_to support_root_path
  end

  test "new path sets and renders" do
    get :new
    assert assigns(:customer_signup)
    assert_template :new
    assert_template layout: "layouts/customer-sign-up"
  end

  test "new path sets and renders with email" do
    get :new, params: { email: 'foo@bar.com'}
    assert assigns(:email)
  end

  test "signup not enabled html" do
    Stronghold::SIGNUPS_ENABLED = false
    get :new
    assert_template :sorry
    assert_template layout: "layouts/customer-sign-up"
  end

  test "signup not enabled json" do
    Stronghold::SIGNUPS_ENABLED = false
    get :new, format: :json
    assert_equal ["Sorry, not currently accepting signups."], json_response['errors']
    assert_response :unprocessable_entity
  end

  test "create path successful html" do
    post :create, params: { email: 'foo@bar.com'}
    assert assigns(:customer_signup)
    assert_redirected_to thanks_path
  end

  test "create path successful json" do
    post :create, params: { email: 'foo@bar.com'}, format: :json
    assert assigns(:customer_signup)
    assert_response :ok
  end

  test "create path failure html" do
    post :create, params: { email: 'foo' }
    assert assigns(:customer_signup)
    assert flash[:alert].length > 0
    assert_response :unprocessable_entity
    assert_template :new
    assert_template layout: "layouts/customer-sign-up"
  end

  test "create path failure json" do
    post :create, params: { email: 'foo'}, format: :json
    assigns(:customer_signup)
    assert_response :unprocessable_entity
    assert json_response['errors'].length > 0
  end

  test "thanks logged in" do
    log_in(@user)
    get :thanks
    assert_redirected_to support_root_path
  end

  test "thanks not logged in" do
    get :thanks
    assert_template :confirm
  end

  test "edit path with valid token" do
    get :edit, params: { token: @invite.token }
    assert assigns(:registration)
    assert_template :edit
    assert_template layout: "layouts/customer-sign-up"
  end

  test "edit path without valid token" do
    assert_raises ActionController::RoutingError do
      get :edit, params: { token: 'foo' }
    end
  end

  test "update path successful unactivated org" do
    mock = Minitest::Mock.new
    mock.expect :unscoped_token, 'blah'
    Fog::Identity.stub(:new, mock) do
      post :update, params: { password: '12345678', token: @invite.token}
      assert session[:user_id]
      assert session[:created_at]
      assert session[:token]
      assert_redirected_to activate_path
    end
  end

  test "update path successful activated org" do
    @organization.update_attributes(self_service: false)
    mock = Minitest::Mock.new
    mock.expect :unscoped_token, 'blah'
    Fog::Identity.stub(:new, mock) do
      post :update, params: { password: '12345678', token: @invite.token}
      assert session[:user_id]
      assert session[:created_at]
      assert session[:token]
      assert_redirected_to support_root_path
    end
  end

  test "update path unsuccessful" do
    post :update, params: { password: '', token: @invite.token }
    assert flash[:alert].length > 0
    assert_response :unprocessable_entity
    assert_template :edit
    assert_template layout: "layouts/customer-sign-up"
  end

end