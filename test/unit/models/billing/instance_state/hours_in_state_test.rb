require 'test_helper'

module Billing
  class TestInstanceStateHoursInState < Minitest::Test
    def setup
      @instance = Instance.make!
      @active_state = InstanceState.make!(
        recorded_at: Time.parse('2015-10-10 09:30:00'),
        state: 'active'
      )
      @inactive_state = InstanceState.make!(
        recorded_at: Time.parse('2015-10-10 16:30:00'),
        state: 'deleted'
      )
    end

    def test_one_active_state_increases_over_time
      Timecop.freeze(Time.parse('2015-10-10 09:40:00')) do
        assert_equal 1, @active_state.hours_in_state
      end

      Timecop.freeze(Time.parse('2015-10-10 10:40:00')) do
        assert_equal 2, @active_state.hours_in_state
      end
    end

    def test_two_active_states_wont_increase_over_time
      @active_state.update_attributes(next_state_id: @inactive_state.id)
      Timecop.freeze(Time.parse('2015-10-10 09:40:00')) do
        assert_equal 7, @active_state.hours_in_state
      end

      Timecop.freeze(Time.parse('2016-10-10 09:40:00')) do
        assert_equal 7, @active_state.hours_in_state
      end
    end

    def test_
      
    end

    def teardown
      DatabaseCleaner.clean  
    end

  end
end