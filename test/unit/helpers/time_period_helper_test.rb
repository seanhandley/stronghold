require 'test_helper'

class TestModel
  include TimePeriodHelper

  def current_user
    @user ||= User.make(organization: Organization.make(created_at: Time.parse('2014-01-01')))
  end
end

class TimePeriodHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def format_date(datetime)
    datetime.strftime("%Y-%m-%d")
  end

  def test_january_2015
    from, to = @model.get_time_period(2015, 1)
    assert_equal "2015-01-01", format_date(from)
    assert_equal "2015-01-31", format_date(to)
  end

  def test_february_2015
    from, to = @model.get_time_period(2015, 2)
    assert_equal "2015-02-01", format_date(from)
    assert_equal "2015-02-28", format_date(to)
  end

  def test_january_2014
    from, to = @model.get_time_period(2014, 1)
    assert_equal "2014-01-01", format_date(from)
    assert_equal "2014-01-31", format_date(to)
  end


  def test_december_2013
    from, to = @model.get_time_period(2013, 12)
    assert_equal "2015-07-01", format_date(from)
    assert_equal "2015-07-03", format_date(to)
  end

end
