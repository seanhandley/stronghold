require 'test_helper'

class TestInstanceStatesChaining < CleanTest
  def setup
    @flavor  = Billing::InstanceFlavor.make!
    @instance = Billing::Instance.make!
    @defaults = {recorded_at: Time.now - 5.minutes, event_name: 'test', state: 'active'}
    @instance.instance_states.create(@defaults)
    @instance.instance_states.create(@defaults.merge(recorded_at: Time.now - 4.minutes))
    @instance.instance_states.create(@defaults.merge(recorded_at: Time.now - 2.minutes))
    @instance.reindex_states
    @state_1, @state_2, @state_3 = @instance.instance_states
  end

  def test_first_state
    assert @state_1.first_state?
    refute @state_1.last_state?
    assert_equal @state_1.next_state.id, @state_2.id
    refute @state_1.previous_state
  end

  def test_second_state
    refute @state_2.first_state?
    refute @state_2.last_state?
    assert_equal @state_2.next_state.id, @state_3.id
    assert_equal @state_2.previous_state.id, @state_1.id
  end

  def test_third_state
    refute @state_3.first_state?
    assert @state_3.last_state?
    refute @state_3.next_state
    assert_equal @state_3.previous_state.id, @state_2.id
  end

  def test_adding_new_states_to_states_without_traversal_data
    [@state_1, @state_2, @state_3].each {|s| s.update_column(:previous_state_id, nil); s.update_column(:next_state_id, nil)}
    [@state_1, @state_2, @state_3].each do |s|
      refute s.next_state
      refute s.previous_state
    end
    @state_4 = @instance.instance_states.create(@defaults.merge(recorded_at: Time.now - 1.minutes))
    @instance.reindex_states

    [@state_1, @state_2, @state_3, @state_4].each(&:reload)

    assert @state_1.first_state?
    refute @state_1.last_state?
    assert_equal @state_1.next_state.id, @state_2.id
    refute @state_1.previous_state
    refute @state_2.first_state?
    refute @state_2.last_state?
    assert_equal @state_2.next_state.id, @state_3.id
    assert_equal @state_2.previous_state.id, @state_1.id
    refute @state_3.first_state?
    refute @state_3.last_state?
    assert_equal @state_3.next_state.id, @state_4.id
    assert_equal @state_3.previous_state.id, @state_2.id
    refute @state_4.first_state?
    assert @state_4.last_state?
    refute @state_4.next_state
    assert_equal @state_4.previous_state.id, @state_3.id
  end
end