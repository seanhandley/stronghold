require 'test_helper'

class TestAntiFraud < CleanTest
  def setup
    @organization = Organization.make!(stripe_customer_id: "foo")
  end

  def test_charge_succeeds_happy_path
    mock_charge = Minitest::Mock.new
    mock_refund = Minitest::Mock.new

    mock_charge.expect(:id, "foo")
    mock_charge.expect(:status, "succeeded")
    mock_refund.expect(:status, "succeeded")

    charge_args = {amount: AntiFraud::TEST_CHARGE_AMOUNT, currency: 'gbp',
                   customer: "foo", description: "Test charge for foo"}

    Stripe::Charge.stub(:create, mock_charge, charge_args) do
      Stripe::Refund.stub(:create, mock_refund, {charge: "foo"}) do
        status, message = AntiFraud.test_charge_succeeds?(@organization)
        assert status
        assert_equal "Test charge succeeded.", message
      end
    end
    mock_charge.verify
    mock_refund.verify
  end

  def test_charge_organization_has_no_stripe_id
    @organization = Organization.make!(stripe_customer_id: nil)
    mock_charge = Minitest::Mock.new

    charge_args = {amount: AntiFraud::TEST_CHARGE_AMOUNT, currency: 'gbp',
                   customer: 'foo', description: "Test charge for customer with no stripe id"}


    Stripe::Charge.stub(:create, mock_charge, {charge: "foo"}) do
      status, message = AntiFraud.test_charge_succeeds?(@organization)
      refute status
      refute_equal "Test charge succeeded.", message
    end
    mock_charge.verify
  end


  def test_charge_fails_to_create_charge
    mock_charge = Minitest::Mock.new

    mock_charge.expect(:id, "foo")
    mock_charge.expect(:status, "failed")

    charge_args = {amount: AntiFraud::TEST_CHARGE_AMOUNT, currency: 'gbp',
                   customer: "foo", description: "Test failed charge for foo"}

    Stripe::Charge.stub(:create, mock_charge, {charge: "foo"}) do
      status, message = AntiFraud.test_charge_succeeds?(@organization)
      refute status
      refute_equal "Test charge succeeded.", message
    end
    mock_charge.verify
  end
  #
  # def test_charge_fails_to_create_refund
  #   flunk # TO DO: Make this pass
  # end
  #
  # def test_charge_handles_stripe_api_errors
  #   flunk # TO DO: Make this pass
  # end
end
