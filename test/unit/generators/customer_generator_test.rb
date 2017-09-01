require 'test_helper'

class TestCustomerGenerator < CleanTest
  def setup
    @valid_params = {organization_name: 'Testy', email: 'testy@customer.com',
                     organization: {product_ids: [1,2]}, extra_projects: ""}
    [:compute, :storage, :colocation].each {|p| Product.make!(p)}
  end

  def test_valid_params_succeed
    VCR.use_cassette('customer_generator_valid') do
      customer = CustomerGenerator.new(@valid_params)
      assert customer.generate!
      refute customer.errors.present?
    end  
  end

  def test_refuses_empty_organization_name
    customer = CustomerGenerator.new(@valid_params.merge(organization_name: ''))
    refute customer.generate!
    assert customer.errors.present?
  end

  def test_refuses_invalid_or_empty_emails
    ['','foo','foo@','foo@a','foo@a.'].each do |email|
      customer = CustomerGenerator.new(@valid_params.merge(email: email))
      refute customer.generate!
      assert customer.errors.present?
    end
  end

  def test_refuses_email_if_it_exists
    UserNoCallbacks.create email: 'testy@customer.com', password: 'Password1',
                           first_name: 'test', last_name: 'test'
    customer = CustomerGenerator.new(@valid_params)
    refute customer.generate!
    assert customer.errors.present?
  end

  def test_refuses_unless_at_least_one_product
    customer = CustomerGenerator.new(@valid_params.merge(organization: { product_ids: []}))
    refute customer.generate!
    assert customer.errors.present?
  end

  def test_refuses_unless_at_products_exist
    customer = CustomerGenerator.new(@valid_params.merge(organization: { product_ids: [45]}))
    refute customer.generate!
    assert customer.errors.present?
  end

  def test_organization_creates_primary_project
    VCR.use_cassette('customer_generator_valid') do
      assert_equal 0, Organization.all.count
      CustomerGenerator.new(@valid_params).generate!
      assert_equal 1, Organization.all.count
      assert Organization.first.primary_project
    end  
  end

  def test_creates_extra_projects
    VCR.use_cassette('customer_generator_valid_multiple_projects') do
      CustomerGenerator.new(@valid_params.merge(extra_projects: 'foo,bar')).generate!
      assert_equal 3, Organization.first.projects.count
    end  
  end

  def test_invite_is_created
    VCR.use_cassette('customer_generator_valid') do
      assert_equal 0, Invite.all.count
      CustomerGenerator.new(@valid_params).generate!
      assert_equal 1, Invite.all.count
    end  
  end

end