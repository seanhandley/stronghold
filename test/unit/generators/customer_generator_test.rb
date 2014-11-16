require 'test_helper'

class TestCustomerGenerator < Minitest::Test
  def setup
    @valid_params = {organization_name: 'Testy', email: 'testy@customer.com',
                     organization: {product_ids: [1,2]}, extra_tenants: ""}
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
    skip 'pending'
  end

  def test_refuses_unless_at_least_one_product
    skip 'pending'
  end

  def test_refuses_invalid_tenant_names
    skip 'pending'
  end

  def test_organization_creates_tenant
    skip 'pending'
  end

  def test_tenant_creates_os_tenant
    skip 'pending'
  end

  def test_os_tenant_has_zero_quotas_for_colo_only
    skip 'pending'
  end

  def test_creates_extra_tenants
    skip 'pending'
  end

  def test_os_tenant_has_default_network
    skip 'pending'
  end

  def test_invite_is_created
    skip 'pending'
  end

  def test_mailer_is_asked_to_deliver_invite
    skip 'pending'
  end

  def teardown
    DatabaseCleaner.clean  
  end

end