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
    Timecop.freeze(Time.now.utc + @voucher.duration.month + 1.day) do
      refute @organization.organization_vouchers.first.active?
    end
  end

  def test_voucher_can_only_be_applied_once_per_organization
    assert_raises ActiveRecord::RecordNotUnique do
      @organization.vouchers << @voucher
      @organization.vouchers << @voucher
    end
  end

  def test_voucher_reports_expired
    refute @voucher.expired?
    Timecop.freeze(@voucher.expires_at + 1.day) do
      assert @voucher.expired?
    end
  end

  def test_voucher_reports_applied
    refute @voucher.applied?
    @organization.vouchers << @voucher
    assert @voucher.applied?
  end
  
  def test_voucher_can_be_destroyed_if_it_has_no_orgs
    assert @voucher.destroy
  end

  def test_voucher_cannot_be_destroyed_if_it_has_orgs
    @organization.vouchers << @voucher
    refute @voucher.destroy
  end

  def test_voucher_reports_expiry
    Timecop.freeze(Time.now.utc) do
      @organization.vouchers << @voucher
      assert_equal Time.now.utc.to_date + @voucher.duration.months,
                   @organization.organization_vouchers.first.expires_at.to_date
    end
  end

  def test_organization_reports_active_vouchers
    from, to = Time.now.utc - 1.day, Time.now.utc + 1.month
    assert_equal 0, @organization.active_vouchers(from, to).count
    @organization.vouchers << @voucher
    assert_equal 1, @organization.active_vouchers(from, to).count
    assert_equal 0, @organization.active_vouchers(@organization.organization_vouchers.first.expires_at,
                                                  @organization.organization_vouchers.first.expires_at + 1.month
                                                  ).count
  end

  def teardown
    DatabaseCleaner.clean  
  end
end