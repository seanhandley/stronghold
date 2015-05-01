require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    session[:user_id]    = @user.id
    session[:created_at] = Time.now.utc
    session[:token]      = SecureRandom.hex
    @organization        = @user.organization
  end

  test "cannot access new, index, create when logged in" do
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
    delete :destroy, id: @user.id
    assert_redirected_to sign_in_path
    assert_nil session[:user_id]
  end
end