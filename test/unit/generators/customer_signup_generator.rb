require 'test_helper'

class TestCustomerSignupGenerator < CleanTest
  def setup
    Product.make!(:compute)
    Product.make!(:storage)
    @customer_signup = CustomerSignup.make!
    @customer = CustomerSignupGenerator.new(@customer_signup.id)
  end

  def test_cs_succeeds
    assert @customer.generate!
  end

  def test_set_state_to_fresh
    @customer.generate!
    assert_equal 'fresh', Organization.first.current_state
  end

  def test_sets_products
    @customer.generate!
    assert Organization.first.compute?
    assert Organization.first.storage?
  end

  def test_disables_primary_tenated
    @organization = Organization.make!
    mock = Minitest::Mock.new
    mock.expect(:disable!, nil)
    mock.expect(:id, Project.first.id)
    Organization.stub(:create!, @organization) do
      @organization.stub(:primary_project, mock) do 
        @customer.generate!
      end
    end
    mock.verify
  end

  def test_invite_is_created
    assert_equal 0, Invite.all.count
    @customer.generate!
    assert_equal 1, Invite.all.count
  end

  def test_sets_quotas
    @customer.generate!
    assert Project.first.quota_set
  end

  def tests_notifies_of_signup
    args = [:new_signup, "New user signed up: #{@customer_signup.email} becoming organization 1"]
    Notifications.stub(:notify, nil, args) do
      @customer.generate!
    end
  end

end