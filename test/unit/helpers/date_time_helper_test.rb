require 'test_helper'

class TestModel
  include DateTimeHelper
end

class DateTimeHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def run_office_hours_test(time_string, operation, message)
    VCR.use_cassette('bank_holidays') do
      Timecop.freeze(DateTime.parse(time_string)) do
        send operation, @model.uk_office_is_open?, message
      end
    end
  end

  def test_office_is_closed_at_0859_August_19th_2015
    run_office_hours_test "2015-08-19 08:59:59 BST", :refute, 'office should not be open yet'
  end

  def test_office_is_open_at_0900_August_19th_2015
    run_office_hours_test "2015-08-19 09:00:00 BST", :assert, 'office should be open now'
  end

  def test_office_is_open_at_1659_August_19th_2015
    run_office_hours_test "2015-08-19 16:59:59 BST", :assert, 'office should not be closed yet'
  end

  def test_office_is_closed_at_1700_August_19th_2015
    run_office_hours_test "2015-08-19 17:00:00 BST", :refute, 'office should be closed now'
  end

  def test_office_is_closed_at_0900_August_22nd_2015
    run_office_hours_test "2015-08-22 09:00:00 BST", :refute, 'office should be closed (Saturday)'
  end

  def test_office_is_closed_at_0900_August_23rd_2015
    run_office_hours_test "2015-08-23 09:00:00 BST", :refute, 'office should be closed (Sunday)'
  end

  def test_office_is_open_at_0900_November_24th_2015
    run_office_hours_test "2015-11-24 09:00:00 GMT", :assert, 'office should be open now (BST is over)'
  end

  def test_office_is_open_at_0900_August_19th_2015
    run_office_hours_test "2015-08-19 09:00:00 BST", :assert, 'office should be open now'
  end

  def test_office_is_closed_at_1200_August_31st_2015
    run_office_hours_test "2015-08-31 12:00:00 BST", :refute, 'office should be closed now (August Bank Holiday)'
  end

  def test_office_is_closed_at_1200_December_25th_2015
    run_office_hours_test "2015-12-25 12:00:00 GMT", :refute, 'office should be closed now (Christmas Day)'
  end

  def test_office_is_closed_at_1200_December_28th_2015
    run_office_hours_test "2015-12-28 12:00:00 GMT", :refute, 'office should be closed now (Late Boxing Day)'
  end

end