require 'test_helper'

class TestOnboarding < Minitest::Test
  def test_initial_user_and_subsequent_org_creation
    @invite = Invite.make!(:power_user)
    
  end

  def test_subsequent_user_signup
    @invite = Invite.make!
  end
end