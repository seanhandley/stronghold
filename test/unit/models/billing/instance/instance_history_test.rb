require 'test_helper'

class TestInstanceHistory < CleanTest
  def setup
    @start_time    = Time.parse("2016-08-18 13:13:23")
    @medium_flavor = Billing::InstanceFlavor.make!
    @large_flavor  = Billing::InstanceFlavor.make!(:large)
    @instance      = Billing::Instance.make!
    @defaults      = {recorded_at: @start_time - 5.days, event_name: 'boot', state: 'active', instance_flavor: @medium_flavor}

    @instance.instance_states.create(@defaults)
    @instance.instance_states.create(@defaults.merge(recorded_at: @start_time - 4.days, state: 'stopped'))
    @instance.instance_states.create(@defaults.merge(recorded_at: @start_time - 3.days, state: 'active'))
    @instance.instance_states.create(@defaults.merge(recorded_at: @start_time - 2.days, state: 'active', instance_flavor: @large_flavor))
    @instance.instance_states.create(@defaults.merge(recorded_at: @start_time - 24.hours, state: 'stopped', instance_flavor: @large_flavor))
    @instance.instance_states.create(@defaults.merge(recorded_at: @start_time - 22.hours, state: 'active', instance_flavor: @large_flavor))
    @instance.reindex_states
  end

  def test_instance_seconds
    Timecop.freeze(@start_time) do
      assert_equal 1.day,    @instance.instance_states[0].seconds(@start_time - 6.days, @start_time)
      assert_equal 1.day,    @instance.instance_states[1].seconds(@start_time - 6.days, @start_time)
      assert_equal 1.day,    @instance.instance_states[2].seconds(@start_time - 6.days, @start_time)
      assert_equal 1.day,    @instance.instance_states[3].seconds(@start_time - 6.days, @start_time)
      assert_equal 2.hours,  @instance.instance_states[4].seconds(@start_time - 6.days, @start_time)
      assert_equal 22.hours, @instance.instance_states[5].seconds(@start_time - 6.days, @start_time)
    end
  end

  def test_history_whole
    Timecop.freeze(@start_time) do
      assert_equal 6, @instance.history(@start_time - 6.days, @start_time).count
    end
  end

  def test_history_last_36_hours
    Timecop.freeze(@start_time) do
      assert_equal 3, @instance.history(@start_time - 36.hours, @start_time).count
    end
  end

  def test_history_last_4_hours
    Timecop.freeze(@start_time) do
      assert_equal 1, @instance.history(@start_time - 4.hours, @start_time).count
    end
  end

  def test_history_first_4_hours
    Timecop.freeze(@start_time) do
      assert_equal 1, @instance.history(@start_time - 120.hours, @start_time - 116.hours).count
    end
  end

  def test_history_pre_4_hours_adjoined
    Timecop.freeze(@start_time) do
      assert_equal 1, @instance.history(@start_time - 124.hours, @start_time - 120.hours).count
    end
  end

  def test_history_pre_4_hours_unadjoined
    Timecop.freeze(@start_time) do
      assert_equal 0, @instance.history(@start_time - 125.hours, @start_time - 121.hours).count
    end
  end

  def test_billable_history_whole
    Timecop.freeze(@start_time) do
      assert_equal 4, @instance.billable_history(@start_time - 6.days, @start_time).count
    end
  end

  def test_history_middle_hours
    Timecop.freeze(@start_time) do
      assert_equal 3, @instance.history(@start_time - 24.hours, @start_time).count
    end
  end

  def test_billable_history_last_36_hours
    Timecop.freeze(@start_time) do
      assert_equal 2, @instance.billable_history(@start_time - 36.hours, @start_time).count
    end
  end

  def test_billable_history_last_4_hours
    Timecop.freeze(@start_time) do
      assert_equal 1, @instance.billable_history(@start_time - 4.hours, @start_time).count
    end
  end

  def test_billable_history_first_4_hours
    Timecop.freeze(@start_time) do
      assert_equal 1, @instance.billable_history(@start_time - 120.hours, @start_time - 116.hours).count
    end
  end

  def test_billable_history_pre_4_hours
    Timecop.freeze(@start_time) do
      assert_equal 1, @instance.billable_history(@start_time - 124.hours, @start_time - 120.hours).count
    end
  end

  def test_billable_history_post_4_hours
    Timecop.freeze(@start_time) do
      assert_equal 1, @instance.billable_history(@start_time, @start_time + 4.hours).count
    end
  end

  def test_billable_history_middle_hours
    Timecop.freeze(@start_time) do
      assert_equal 2, @instance.billable_history(@start_time - 24.hours, @start_time).count
    end
  end

  def test_billable_seconds_whole
    Timecop.freeze(@start_time) do
      billable_seconds = @instance.billable_seconds(@start_time - 6.days, @start_time)
      assert_equal 94.hours, billable_seconds.values.sum
      assert_equal 48.hours, billable_seconds['flavor_id']
      assert_equal 46.hours, billable_seconds['large_flavor_id']
    end
  end

  def test_billable_seconds_last_36_hours
    Timecop.freeze(@start_time) do
      billable_seconds = @instance.billable_seconds(@start_time - 36.hours, @start_time)
      assert_equal 34.hours, billable_seconds.values.sum
      assert_equal 34.hours, billable_seconds['large_flavor_id']
    end
  end

  def test_billable_seconds_last_4_hours
    Timecop.freeze(@start_time) do
      billable_seconds = @instance.billable_seconds(@start_time - 4.hours, @start_time)
      assert_equal 4.hours, billable_seconds.values.sum
      assert_equal 4.hours, billable_seconds['large_flavor_id']
    end
  end

  def test_billable_seconds_first_4_hours
    Timecop.freeze(@start_time) do
      billable_seconds = @instance.billable_seconds(@start_time - 120.hours, @start_time - 116.hours)
      assert_equal 4.hours, billable_seconds.values.sum
      assert_equal 4.hours, billable_seconds['flavor_id']
    end
  end

  def test_billable_seconds_pre_4_hours
    Timecop.freeze(@start_time) do
      billable_seconds = @instance.billable_seconds(@start_time - 124.hours, @start_time - 120.hours)
      assert_equal 0.hours, billable_seconds.values.sum
    end
  end

  def test_billable_seconds_post_4_hours
    Timecop.freeze(@start_time) do
      billable_seconds = @instance.billable_seconds(@start_time, @start_time + 4.hours)
      assert_equal 4.hours, billable_seconds.values.sum
      assert_equal 4.hours, billable_seconds['large_flavor_id']
    end
  end

  def test_billable_seconds_post_middle_hours
    Timecop.freeze(@start_time) do
      billable_seconds = @instance.billable_seconds(@start_time-24.hours, @start_time)
      assert_equal 22.hours, billable_seconds.values.sum
      assert_equal 22.hours, billable_seconds['large_flavor_id']
    end
  end

  def test_billable_seconds_in_future
    d = @start_time + 1.year
    Timecop.freeze(d) do
      billable_seconds = @instance.billable_seconds(d, d + 24.hours)
      assert_equal 24.hours, billable_seconds.values.sum
      assert_equal 24.hours, billable_seconds['large_flavor_id']
    end
  end
end
