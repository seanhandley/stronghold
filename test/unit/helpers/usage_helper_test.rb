require 'test_helper'

class TestModel
  include UsageHelper
  include Rails.application.routes.url_helpers

  def current_user
    @user ||= User.make(organization: Organization.make(created_at: signed_up))
  end

  def current_organization
    current_user.organization
  end

  def signed_up
    Time.parse('2014-01-01')
  end

  def params
    {
      month: Date.today.month,
      year: Date.today.year
    }
  end
end

class UsageHelperTest < CleanTest
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

  def test_time_period_without_args
    from_a, to_a = Time.zone.now.beginning_of_month, Time.zone.now
    from_b, to_b = @model.get_time_period(nil,nil)
    assert_in_delta from_a, from_b, 0.01
    assert_in_delta to_a, to_b, 0.01
  end

  def test_usages_for_select
    Timecop.freeze(Time.parse('2014-03-02')) do
      options = "<option selected=\"selected\" value=\"/account/usage?month=3&amp;year=2014\">March 2014</option>\n<option value=\"/account/usage?month=2&amp;year=2014\">February 2014</option>\n<option value=\"/account/usage?month=1&amp;year=2014\">January 2014</option>"
      assert_equal options, @model.usages_for_select(@model.current_organization)
    end

    Timecop.freeze(Time.parse('2014-01-31')) do
      options = "<option selected=\"selected\" value=\"/account/usage?month=1&amp;year=2014\">January 2014</option>"
      assert_equal options, @model.usages_for_select(@model.current_organization)
    end
  end

  def test_billing_range
    range = @model.billing_range(@model.current_organization)
    assert_equal @model.current_organization.created_at.beginning_of_month,
                 range.last
    assert_equal Date.today.end_of_month, range.first
    Timecop.freeze(Time.now + 2.years + 3.months) do
      range = @model.billing_range(@model.current_organization)
      assert_equal @model.current_organization.created_at.beginning_of_month,
                 range.last
      assert_equal Date.today.end_of_month, range.first
    end
  end

  def test_architecture_human_name
    assert_equal '-', @model.architecture_human_name(nil)
    assert_equal '-', @model.architecture_human_name('')
    assert_equal 'ARM', @model.architecture_human_name('aarch64')
    assert_equal 'ARM', @model.architecture_human_name('aarch64'.upcase)
    assert_equal 'Intel x86', @model.architecture_human_name('x86_64')
    assert_equal 'Intel x86', @model.architecture_human_name('x86_64'.upcase)
    assert_equal 'foom!', @model.architecture_human_name('foom!')
  end

  def test_state_with_icon
    assert_equal "<i class='fa fa-play text-success'></i> Active", @model.state_with_icon('active')
    assert_equal "<i class='fa fa-pause'></i> Stopped", @model.state_with_icon('stopped')
    assert_equal "<i class='fa fa-eject text-danger'></i> Terminated", @model.state_with_icon('terminated')
    assert_equal 'foom!', @model.state_with_icon('foom!')
  end

end
