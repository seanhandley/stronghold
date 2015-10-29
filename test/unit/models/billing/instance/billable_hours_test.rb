require 'test_helper'

module Billing
  class TestInstanceBillableHours < Minitest::Test
    def setup
      @instance = Instance.make!
      @active_state_a = InstanceState.make!(
        recorded_at: Time.parse('2015-10-10 09:30:00 UTC'),
        state: 'active'
      )
      @inactive_state_a = InstanceState.make!(
        recorded_at: Time.parse('2015-10-10 16:30:00 UTC'),
        state: 'suspended'
      )
      @active_state_b = InstanceState.make!(
        recorded_at: Time.parse('2015-10-11 09:30:00 UTC'),
        state: 'active'
      )
      @inactive_state_b = InstanceState.make!(
        recorded_at: Time.parse('2015-10-11 16:30:00 UTC'),
        state: 'deleted'
      )
      @from = Time.parse('2015-10-09 09:00:00 UTC')
      @to = Time.parse('2015-10-12 09:00:00 UTC')
    end

    def test_billable_hours_for_active_state
      @active_state_a.update_attributes(instance_id: @instance.id)

      Timecop.freeze(Time.parse('2015-10-10 09:40:00 UTC')) do
        assert_equal 1, @instance.billable_hours(@from, @to)
      end
    end

    def test_billable_hours_for_multiple_states_with_broad_range
      set_sequence_of_multiple_states

      Timecop.freeze(Time.parse('2015-10-10 09:40:00')) do
        assert_equal 14, @instance.billable_hours(@from, @to)
      end    
    end

    def test_billable_hours_for_multiple_states_with_narrow_range_a
      assert_equal 10, narrow_range_billable_hours('2015-10-10 11:30:00 UTC', '2015-10-11 14:30:00 UTC')
    end

    def test_billable_hours_for_multiple_states_with_narrow_range_b
      assert_equal 3, narrow_range_billable_hours('2015-10-11 11:30:00 UTC', '2015-10-11 14:30:00 UTC')
    end

    def test_billable_hours_for_multiple_states_with_narrow_range_c
      assert_equal 0, narrow_range_billable_hours('2015-10-10 17:30:00 UTC', '2015-10-11 08:30:00 UTC')
    end

    def test_billable_hours_for_multiple_states_with_narrow_range_d
      assert_equal 2, narrow_range_billable_hours('2015-10-10 07:30:00 UTC', '2015-10-10 11:30:00 UTC')
    end

    def test_billable_hours_for_multiple_states_with_narrow_range_e
      assert_equal 1, narrow_range_billable_hours('2015-10-11 15:30:00 UTC', '2015-10-12 11:30:00 UTC')
    end

    def test_billable_hours_for_multiple_states_with_narrow_range_f
      assert_equal 0, narrow_range_billable_hours('2015-10-11 16:30:00 UTC', '2015-10-11 17:30:00 UTC')
    end

    def test_billable_hours_for_multiple_states_with_narrow_range_g
      assert_equal 0, narrow_range_billable_hours('2015-10-10 07:30:00 UTC', '2015-10-10 09:30:00 UTC')
    end

    def test_billable_hours_before_range
      assert_equal 0, narrow_range_billable_hours('2015-10-7 11:30:00 UTC', '2015-10-8 14:30:00 UTC')
    end

    def test_billable_hours_after_range
      assert_equal 0, narrow_range_billable_hours('2015-10-17 11:30:00 UTC', '2015-10-18 14:30:00 UTC')
    end

    def test_billable_hours_with_sequential_active_periods_open_ended
      @active_state_a.update_attributes(instance_id: @instance.id, next_state_id: @active_state_b.id)
      @active_state_b.update_attributes(instance_id: @instance.id, previous_state_id: @active_state_a.id)
      Timecop.freeze(Time.parse('2015-10-11 17:30:00 UTC')) do
        assert_equal 32, @instance.billable_hours(Time.parse('2015-10-7 11:30:00 UTC'), Time.parse('2015-10-11 17:30:00 UTC'))
      end
    end

    def test_billable_hours_with_sequential_active_periods_closed_by_inactive
      @inactive_state_a.update_attributes(instance_id: @instance.id, next_state_id: @active_state_a.id)
      @active_state_a.update_attributes(instance_id: @instance.id, next_state_id: @active_state_b.id, previous_state_id: @inactive_state_a.id)
      @active_state_b.update_attributes(instance_id: @instance.id, previous_state_id: @active_state_a.id, next_state_id: @inactive_state_b.id)
      @inactive_state_b.update_attributes(instance_id: @instance.id, previous_state_id: @active_state_b.id)
      assert_equal 31, @instance.billable_hours(Time.parse('2015-10-7 11:30:00 UTC'), Time.parse('2015-10-15 17:30:00 UTC'))
    end

    def teardown
      DatabaseCleaner.clean  
    end

    private

    def set_sequence_of_multiple_states
      @active_state_a.update_attributes(instance_id: @instance.id, next_state_id: @inactive_state_a.id)
      @inactive_state_a.update_attributes(instance_id: @instance.id, next_state_id: @active_state_b.id, previous_state_id: @active_state_a.id)
      @active_state_b.update_attributes(instance_id: @instance.id, next_state_id: @inactive_state_b.id, previous_state_id: @inactive_state_a.id)
      @inactive_state_b.update_attributes(instance_id: @instance.id, previous_state_id: @active_state_b.id)
    end

    def narrow_range_billable_hours(from, to)
      set_sequence_of_multiple_states
      @instance.billable_hours(Time.parse(from), Time.parse(to))
    end

  end
end