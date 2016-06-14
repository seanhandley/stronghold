require 'test_helper'

class TestModel
  include StatesHelper
end

class StatesHelperTest < CleanTest  

  def setup
    @options_for_states = TestModel.new.options_for_states(Organization.make!)
  end

  def test_options_count_matches_organization_states_minus_one
    assert_equal Organization::OrganizationStates.constants.count-1, @options_for_states.scan(/\<option/).count
  end

  def test_shows_human_readable_states
    assert @options_for_states.include?("Has No Payment Methods")
  end

  def test_contains_representative_data
    assert @options_for_states.include?("no_payment_methods")
  end

  def test_does_not_include_fresh
    refute @options_for_states.include?("Fresh")
  end

end