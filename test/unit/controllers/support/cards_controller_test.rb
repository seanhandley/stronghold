require 'test_helper'

class Support::CardsControllerTest < CleanControllerTest
  setup do
    @user = User.make!(password: 'Password1', uuid: '1234')
    @organization = @user.primary_organization
    @customer_signup = CustomerSignup.make!
    @organization.update_attributes customer_signup: @customer_signup
    @args = {
      params: {
        signup_uuid: @customer_signup.uuid,
        stripe_token: SecureRandom.hex,
        organization_name: "foo",
        address_line1: "1 Street",
        address_line2: "",
        address_city: "Place",
        postcode: 'A12 3BC',
        address_country: ['GB']
      }
    }
    @voucher = Voucher.make!
    log_in(@user)
  end

  test "new when unactivated" do
    get :new
    assert assigns(:location)
    assert assigns(:customer_signup)
  end

  test "new when already activated" do
    @organization.update_attributes(self_service: false)
    get :new
    assert_redirected_to support_root_path
  end
 
  # AJAX calls to Stripe verify the card/address
  # If successful, the customer signup model is updated
  # before the :create action is called
  test "create when not ready" do
    post :create, params: {signup_uuid: @customer_signup.uuid}
    assert_response :unprocessable_entity
    assert assigns(:customer_signup)
    assert_template :new
  end

  test "create successful" do
    @customer_signup.stub(:ready?, true) do
      CustomerSignup.stub(:find_by_uuid, @customer_signup) do
        Rails.cache.stub(:fetch, 'Password1') do
          post :create, @args
          assert_equal 1, Starburst::Announcement.all.count
          assert_redirected_to activated_path
        end
      end
    end
  end

  test "create successful with voucher" do
    @customer_signup.stub(:ready?, true) do
      CustomerSignup.stub(:find_by_uuid, @customer_signup) do
        Rails.cache.stub(:fetch, 'Password1') do
          post :create, params: @args[:params].merge(discount_code: @voucher.code)
          assert_equal 1, @organization.vouchers.count
        end
      end
    end
  end

end
