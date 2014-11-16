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

  def teardown
    DatabaseCleaner.clean  
  end

end