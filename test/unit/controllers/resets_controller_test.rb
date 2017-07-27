require 'test_helper'

class ResetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.make!(password: 'Password1')
  end

  test "Can't do anything if logged in" do
    log_in(@user)
    assert_404([
      [:get, :new, nil],
      [:get, :show, {params: {id: 'foo'}}],
      [:post, :create, {params: {reset: {email: 'foo'}}}],
      [:patch, :update, {params: {id: 'foo', password: '12345678'}}]
    ])
  end

  test "new loads and renders" do
    get :new
    assert_response :success
    assert_template :new
  end

  test "can create a new reset with a valid email" do
    post :create, params: { reset: { email: @user.email }}, xhr: true
    assert_response :success
    assert @response.body.include? "check your email"
  end

  test "can't create a new reset with an invalid email" do
    post :create, params: { reset: { email: 'foo' }}, xhr: true
    assert_response :unprocessable_entity
    assert @response.body.include? 'too short'
  end

  test "valid emails pretend to work if the address isn't found" do
    post :create, params: { reset: { email: 'foo@bar.com' }}, xhr: true
    assert_response :success
    assert @response.body.include? "check your email"
  end

  test "can view a reset if it's still valid" do
    reset = Reset.create email: @user.email
    get :show, params: { id: reset.token }
    assert_response :success
    assert assigns(:reset)
    assert_template :show
  end

  test "can't view a reset if it doesn't exist" do
    assert_404 [[:get, :show, {params: {id: 'fdsfds'}}]]
  end

  test "can't view a reset if it's expired" do
    reset = Reset.create email: @user.email
    Timecop.freeze(Time.now + 1.month) do
      assert_404 [[:get, :show, {params: {id: reset.token}}]]
    end
  end

  test "can set a new password for a valid reset" do
    reset = Reset.create email: @user.email
    patch :update, params: {id: reset.token, password: '12345678'}, xhr: true
    assert_response 302
    assert @response.body.include? sign_in_path
  end

  test "can't set a new password for an invalid reset" do
    assert_404 [[:patch, :update, {params: {id: 'foo', password: '12345678', xhr: true}}]]
  end

  test "can't set a new password for an expired reset" do
    reset = Reset.create email: @user.email
    Timecop.freeze(Time.now + 1.month) do
      assert_404 [[:patch, :update, {params: {id: reset.token, password: '12345678', xhr: true}}]]
    end
  end

  test "can't reset password with invalid password" do
    reset = Reset.create email: @user.email
    patch :update, params: { id: reset.token, password: ''}, xhr: true
    assert_response :unprocessable_entity
    assert @response.body.include? 'too short'
  end

end