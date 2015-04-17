require 'test_helper'

class TestVoucherLifetimes < Minitest::Test
  def setup
    @voucher = Voucher.make!
    @organization = Organization.make!
  end

  def test_vouchers_and_orgs_have_zero_assocs
    assert_equal 0, @voucher.organizations.count
    assert_equal 0, @organization.vouchers.count
  end

  def test_voucher_can_be_applied_to_organization
    @organization.vouchers << @voucher
    assert_equal 1, @voucher.organizations.count
    assert_equal 1, @organization.vouchers.count
  end

  def test_voucher_cannot_be_applied_when_expired
    @voucher.update_attributes(expires_at: Time.now - 1.week)
    assert_raises ActiveRecord::RecordInvalid do
      @organization.vouchers << @voucher
    end
  end

  def test_voucher_reports_active_during_duration
    @organization.vouchers << @voucher
    assert @organization.organization_vouchers.first.active?
  end

  def test_voucher_reports_finished_after_duration_elapses
    @organization.vouchers << @voucher
    Timecop.freeze(Date.today + @voucher.duration.month + 1.day) do
      refute @organization.organization_vouchers.first.active?
    end
  end

  def test_voucher_can_only_be_applied_once_per_organization
    assert_raises ActiveRecord::RecordNotUnique do
      @organization.vouchers << @voucher
      @organization.vouchers << @voucher
    end
  end

  def teardown
    DatabaseCleaner.clean  
  end
end