require 'test_helper'

class TestAntiFraud < CleanTest
  def setup
    @organization = Organization.make!(stripe_customer_id: "foo")
  end

  def test_charge_succeeds_happy_path
    mock_charge = Minitest::Mock.new

    mock_charge.expect(:id, "foo")

    charge_args = {amount: AntiFraud::TEST_CHARGE_AMOUNT, currency: 'gbp',
                   customer: "foo", description: "Test charge for foo"}

    Stripe::Charge.stub(:create, mock_charge, charge_args) do
      Stripe::Refund.stub(:create, nil, {charge: "foo"}) do
        status, message = AntiFraud.test_charge_succeeds?(@organization)
        assert status
        assert_equal "Test charge succeeded.", message
      end
    end
    mock_charge.verify
  end

  def test_charge_organization_has_no_stripe_id
    @organization = Organization.make!(stripe_customer_id: nil)
    status, message = AntiFraud.test_charge_succeeds?(@organization)
    refute status
    assert_equal "Organization #{@organization.id} has no stripe id associated.", message
  end


  def test_charge_fails_to_create_charge
    charge_args = {amount: AntiFraud::TEST_CHARGE_AMOUNT, currency: 'gbp',
                   customer: "foo", description: "Test charge for foo"}

    error_message = "Your card was declined"
    Stripe::Charge.stub(:create, -> (_) { raise Stripe::CardError.new(error_message, 'foo', 'bar') }, charge_args) do
      status, message = AntiFraud.test_charge_succeeds?(@organization)
      refute status
      assert_equal error_message, message
    end
  end

  def test_charge_fails_to_create_refund
    mock_charge = Minitest::Mock.new

    mock_charge.expect(:id, "foo")

    charge_args = {amount: AntiFraud::TEST_CHARGE_AMOUNT, currency: 'gbp',
                   customer: "foo", description: "Test charge for foo"}

    error_message = "Bank doesn't like you very much"
    Stripe::Charge.stub(:create, mock_charge, charge_args) do
      Stripe::Refund.stub(:create, -> (_) { raise Stripe::CardError.new(error_message, 'foo', 'bar') }, {charge: "bar"}) do
        status, message = AntiFraud.test_charge_succeeds?(@organization)
        refute status
        assert_equal error_message, message
      end
    end
    mock_charge.verify
  end
end
