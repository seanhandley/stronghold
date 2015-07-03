require 'test_helper'

class TestModel
  include TimePeriodHelper

  def current_user
    @user ||= User.make(organization: Organization.make(created_at: signed_up))
  end

  def signed_up
    Time.parse('2014-01-01')
  end
end

class TimePeriodHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def format_date(datetime)
    datetime.strftime("%Y-%m-%d")
  end

  def test_historic_month_january_2015
    from, to = @model.get_time_period(2015, 1)
    assert_equal "2015-01-01", format_date(from)
    assert_equal "2015-01-31", format_date(to)
  end

  def test_historic_month_february_2015
    from, to = @model.get_time_period(2015, 2)
    assert_equal "2015-02-01", format_date(from)
    assert_equal "2015-02-28", format_date(to)
  end

  def test_signup_month_january_2014
    from, to = @model.get_time_period(@model.signed_up.year, @model.signed_up.month)
    assert_equal "2014-01-01", format_date(from)
    assert_equal "2014-01-31", format_date(to)
  end

  def test_current_month_up_to_today
    Timecop.freeze(Time.parse("2015-07-15 12:00:00")) do
      from, to = @model.get_time_period(2015, 7)
      assert_equal "2015-07-01", format_date(from)
      assert_equal "2015-07-15", format_date(to)
    end
  end

  def test_month_preceeding_signup_month_defaults_to_current_month
    Timecop.freeze(Time.parse("2015-07-03 12:00:00")) do
      dt = @model.signed_up - 1.month
      from, to = @model.get_time_period(dt.year, dt.month)
      assert_equal "2015-07-01", format_date(from)
      assert_equal "2015-07-03", format_date(to)
    end
  end

end
