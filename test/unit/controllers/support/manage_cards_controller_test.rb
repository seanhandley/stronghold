require 'test_helper'

class Support::ManageCardsControllerTest < ActionController::TestCase
  setup do
    @user = User.make!
    @organization = @user.organizations.first 
    @stripe_id = "cus_7QbAaReJ8NlEZS"
    @card_1 = {card: {
      number: "4242424242424242",
      exp_month: 11,
      exp_year: Date.today.year+1,
      cvc: '314'
      }
    }
    @card_2 = {card: {
      number: "4012888888881881",
      exp_month: 3,
      exp_year: Date.today.year+1,
      cvc: '345'
      }
    }
    @organization.update_attributes(stripe_customer_id: @stripe_id)
    @role = Role.make!(organization: @organization, power_user: true)
    @user.update_attributes(roles: [@role])
    log_in(@user)
  end

  def stripe_token(card)
    Stripe::Token.create(card).id
  end

  test "Can't do anything unless power user" do
    @user.update_attributes(roles: [])
    refute @user.power_user?
    VCR.use_cassette('stripe_has_valid_sources') do
      assert_404([
        [:get, :index, nil],
        [:post, :create, {params: {id: 1, stripe_token: 'foo'}}],
        [:patch, :update, {params: { id: 1}}],
        [:delete, :destroy, {params: { id: 1}}]
      ])
    end
  end

  test "shows list of customer's cards on Stripe" do
    VCR.use_cassette('stripe_list_cards') do
      get :index
      assert assigns(:cards)
    end
  end

  test "can add a new card" do
    VCR.use_cassette('stripe_add_new_card') do
      post :create, params: {stripe_token: stripe_token(@card_1)}
      assert flash[:notice].include?('success')
      assert_redirected_to support_manage_cards_path
    end
  end

  test "Can't re-add the same card" do
    VCR.use_cassette('stripe_readd_card') do
      post :create, params: {stripe_token: stripe_token(@card_2)}
      assert flash[:notice].include?('success')
      assert_redirected_to support_manage_cards_path
      @controller.instance_variable_set(:@stripe_customer, nil)
      post :create, params: {stripe_token: stripe_token(@card_2)}
      assert flash[:alert].include?('already')
      assert_redirected_to support_manage_cards_path
    end
  end

  test "Can set a card to be the default card" do
    VCR.use_cassette('stripe_set_default') do
      patch :update, params: {id: 'card_17C7HpAR2MipIX2iOeADBBJE'}
      assert flash[:notice].include?('success')
      assert_redirected_to support_manage_cards_path
    end
  end

  test "Can destroy a card if it isn't default" do
    VCR.use_cassette('stripe_can_delete_non_default') do
      delete :destroy, params: {id: 'card_17C7HdAR2MipIX2i7ERoDcyX'}
      assert flash[:notice].include?('success')
      assert_redirected_to support_manage_cards_path
    end
  end

  test "Can't destroy the default card" do
    VCR.use_cassette('stripe_cannot_delete_default') do
      delete :destroy, params: {id: 'card_17C7HpAR2MipIX2iOeADBBJE'}
      assert flash[:alert].include?('add another')
      assert_redirected_to support_manage_cards_path
    end
  end

  test "Handles bad customer ID" do
    VCR.use_cassette('stripe_invalid_id') do
      @organization.update_attributes(stripe_customer_id: 'bork bork')
      get :index
      assert flash[:error].include?("something went wrong")
    end
  end

  def teardown
    DatabaseCleaner.clean
  end

end