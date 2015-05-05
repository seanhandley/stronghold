require 'test_helper'

class TestVoucherValidations < Minitest::Test
  def setup
    @voucher = Voucher.make!
    @organization = Organization.make!
  end

  def test_valid_by_default
    assert @voucher.valid?
  end

  def test_duplicate_codes_invalid
    refute @voucher.dup.valid?
  end

  def test_value_between_zero_and_one_hundred
    @voucher.discount_percent = 101
    refute @voucher.valid?
    @voucher.discount_percent = 0
    refute @voucher.valid?
    @voucher.discount_percent = -1
    refute @voucher.valid?
  end

  def test_duration_greater_than_zero
    @voucher.duration = 0
    refute @voucher.valid?
    @voucher.duration = -1
    refute @voucher.valid?
  end

  def test_generates_code_if_absent
    v = @voucher.dup
    v.code = nil
    v.save
    assert v.code.length > 0
  end

  def test_voucher_active_scope
    assert_equal 1, Voucher.active.count
  end

  def test_voucher_expired_scope
    assert_equal 0, Voucher.expired.count
    Timecop.freeze(@voucher.expires_at - 1.second) do
      assert_equal 0, Voucher.expired.count
    end
    Timecop.freeze(@voucher.expires_at) do
      assert_equal 1, Voucher.expired.count
    end
  end

  def test_generates_code
    @voucher2 = Voucher.make!(code: nil)
    assert @voucher2.valid?
    assert @voucher2.code.length > 0
  end

  def teardown
    DatabaseCleaner.clean  
  end
end