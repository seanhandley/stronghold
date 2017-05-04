require 'test_helper'

class TestInviteValidations < CleanTest
  def setup
    @invite = Invite.make!
    @power_invite = Invite.make!(:power_user)
    @expired_invite = Invite.make!(:expired)
  end

  def test_invalid_when_blank
    refute Invite.new.valid?
  end

  def test_valid_with_sample_data
    [@invite, @power_invite].each {|i| assert i.valid? }
  end

  def test_invalid_with_no_email
    @invite.email = ''
    refute @invite.valid?
  end

  def test_invalid_with_malformed_email_address
    bad_emails = ['a', 'a@', 'a@a', 'a@a.', '@a.a', 'aaaaaaaaaaaa']
    bad_emails.each {|e| @invite.email = e; refute @invite.valid? }
    @invite.email = 'a@a.a'
    assert @invite.valid?
  end

  def test_invalid_with_no_roles_unless_power_user
    @invite.roles = []
    refute @invite.valid?
    @power_invite.roles = []
    assert @power_invite.valid?
  end

  def test_can_register_by_default
    [@invite, @power_invite].each {|i| assert i.can_register? }
  end

  def test_cant_register_if_token_expired
    refute @expired_invite.can_register?
  end

  def test_cant_register_if_token_used
    @invite.complete!
    refute @invite.can_register?
  end

  def test_has_22_char_token_by_default
    assert @invite.token
    assert_equal 22, @invite.token.length
  end

  def test_generates_new_token_for_each_invite
    invites = (1..10).collect{ Invite.make! }
    assert_equal 10, invites.uniq.count
  end

  def test_expiry_is_creation_time_plus_72_hours
    assert_equal (@invite.created_at + 7.days).utc.to_s, @invite.expires_at.utc.to_s
  end

end
