require 'test_helper'

class TestVoucherLifetimes < Minitest::Test
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

  def test_value_between_zero_and_one
    @voucher.value = 2
    refute @voucher.valid?
    @voucher.value = 0
    refute @voucher.valid?
    @voucher.value = -1
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

  def teardown
    DatabaseCleaner.clean  
  end
end