require 'test_helper'

class TestOrganizationProperties < CleanTest
  def setup
    @compute    = Product.make!(:compute)
    @storage    = Product.make!(:storage)
    @colocation = Product.make!(:colocation)
    @organization = Organization.make!
  end

  def test_staff?
    staff_org = Organization.make!(reference: 'datacentred')
    assert staff_org.staff?
  end

  def test_has_payment_method?
    org = Organization.make!(self_service: false)
    assert org.has_payment_method?

    org = Organization.make!(self_service: true)
    refute org.has_payment_method?

    org = Organization.make!(self_service: true, stripe_customer_id: '1234')
    org.stub(:stripe_has_valid_source?, 'foo', '1234') do
      assert_equal 'foo', org.has_payment_method?
    end
  end

  def test_known_to_payment_gateway?
    org = Organization.make!(self_service: true)
    refute org.known_to_payment_gateway?

    org = Organization.make!(self_service: false)
    assert org.known_to_payment_gateway?

    org = Organization.make!(self_service: true, stripe_customer_id: '1234')
    assert org.known_to_payment_gateway?
  end

  def test_colo?
    refute @organization.colo?
    @organization.products << @colocation
    @organization.save
    assert @organization.colo?
  end

  def test_storage?
    refute @organization.storage?
    @organization.products << @storage
    @organization.save
    assert @organization.storage?
  end

  def test_compute?
    refute @organization.compute?
    @organization.products << @compute
    @organization.save
    assert @organization.compute?
  end

  def test_cloud?
    refute @organization.cloud?
    @organization.products << @colocation
    @organization.save
    refute @organization.cloud?
    @organization.products << @compute
    @organization.save
    assert @organization.cloud?
    @organization.products << @storage
    @organization.save
    assert @organization.cloud?
    @organization.products = [@colocation, @storage]
    @organization.save
    assert @organization.cloud? 
  end

  def test_paying?
    refute @organization.paying?
    @organization.update_attributes(started_paying_at: Time.now)
    assert @organization.paying?
  end

  def test_admin_users
    assert_equal 0, @organization.admin_users.count
    user = User.make!(organizations: [@organization])
    assert_equal 0, @organization.admin_users.count
    role = Role.make!(power_user: true, organization: @organization)
    ous = OrganizationUser.find_by(organization: @organization, user: user)
    role.organization_users << ous
    role.save!
    assert_equal 1, Organization.first.admin_users.count
  end

  def test_new_projects_remaining
    @organization = Organization.make!(projects_limit: 1)
    assert_equal 0, @organization.new_projects_remaining
    @organization.update_attributes(projects_limit: 5)
    assert_equal 4, @organization.new_projects_remaining
  end

  def test_active_vouchers
    assert_equal 0, @organization.active_vouchers(Time.now - 3.months, Time.now).count
    @organization.vouchers << Voucher.make!
    @organization.save
    assert_equal 1, @organization.active_vouchers(Time.now - 3.months, Time.now).count
  end

  def test_payment_card_type
    @organization.update_attributes(customer_signup: CustomerSignup.make!)
    dummy_customer = OpenStruct.new(
      sources: OpenStruct.new(
        data: [
          OpenStruct.new(brand: 'mastercard', funding: 'credit')
        ]
      )
    )
    @organization.customer_signup.stub(:stripe_customer, dummy_customer) do
      assert_equal 'mastercard credit', @organization.payment_card_type
    end
  end

end