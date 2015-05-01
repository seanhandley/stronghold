require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    @organization        = @user.organization
  end

  test "cannot access new, index, create when logged in" do
    log_in
    @organization.stub(:has_payment_method?, true) do
      @organization.stub(:known_to_payment_gateway?, true) do
        [:new, :index, :create].each do |action|
          assert_raises(ActionController::RoutingError) do
            get action
          end
        end
      end
    end
  end

  test "can log out" do
    log_in
    assert session.keys.count > 1
    delete :destroy, id: @user.id
    assert_redirected_to sign_in_path
    assert_equal 1, session.keys.count
    assert_equal "You have been signed out.", session["flash"]["flashes"]["notice"]
  end

  test "admin user logs in successfully" do
    @organization.stub(:has_payment_method?, true) do
      @user.stub(:authenticate, 'token') do
        post :create, user: {password: 'foo'}
        # assert
      end
    end
  end

  test "admin user logs in and is redirected to the next uri" do
  end

  test "admin user fails login because password is wrong" do
  end

  test "admin user logs in for the first time and adds the first card to the account" do
  end

  test "non admin user logs in when payment method is failing" do
  end

  private

  def log_in
    session[:user_id]    = @user.id
    session[:created_at] = Time.now.utc
    session[:token]      = SecureRandom.hex
  end
end
