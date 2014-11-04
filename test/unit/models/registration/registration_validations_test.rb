require 'test_helper'

class TestRegistrationValidations < Minitest::Test
  def setup
    @invite = Invite.make!
    @power_invite = Invite.make!(:power_user)
    @expired_invite = Invite.make!(:expired)
    @password = SecureRandom.base64(16)
    @valid_params = { password: @password,
                      confirm_password: @password,
                      privacy: 'on' }
  end


  def test_refuses_invalid_invites
    registration = RegistrationGenerator.new(@expired_invite, @valid_params)
    refute registration.generate!
    assert registration.errors.present?
  end

  def test_refuses_password_mismatch
    registration = RegistrationGenerator.new(@invite,
                                    @valid_params.merge(password: 'foo'))
    refute registration.generate!
    assert registration.errors.present?   
  end

  def test_refuses_password_too_short
    p = {password: 'foo', confirm_password: 'foo'}
    registration = RegistrationGenerator.new(@invite,
                                    @valid_params.merge(p))
    refute registration.generate!
    assert registration.errors.present?   
  end

  def test_organization_matches_invite
    registration = RegistrationGenerator.new(@invite, @valid_params)
    registration.generate!
    assert_equal registration.organization.id, @invite.organization.id  
  end

  def test_registered_user_has_correct_roles
    registration = RegistrationGenerator.new(@invite, @valid_params)
    registration.generate!
    @invite.roles.each do |role|
      assert registration.user.roles.include? role
    end
  end

  def test_power_invite_creates_owners_role_and_adds_user
    registration = RegistrationGenerator.new(@power_invite, @valid_params)
    registration.generate!
    role = registration.organization.roles.first 
    assert role.power_user?
    assert_equal registration.user.roles.first.id, role.id
  end

  def test_registration_marks_invite_as_complete  
    registration = RegistrationGenerator.new(@invite, @valid_params)
    registration.generate!
    refute registration.invite.can_register?
  end

  def test_registration_cannot_occur_twice
    registration = RegistrationGenerator.new(@invite, @valid_params)
    assert registration.generate!
    refute registration.generate!
  end

  def test_registration_cannot_occur_unless_privacy_is_agreed
    registration = RegistrationGenerator.new(@power_invite,
                                    @valid_params.merge(privacy: ''))
    refute registration.generate!
    assert registration.errors.present?      
  end

  def teardown
    DatabaseCleaner.clean  
  end

end