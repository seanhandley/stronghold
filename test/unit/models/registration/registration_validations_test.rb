require 'test_helper'

class TestRegistrationValidations < Minitest::Test
  def setup
    @invite = Invite.make!
    @power_invite = Invite.make!(:power_user)
    @expired_invite = Invite.make!(:expired)
    @password = SecureRandom.base64(16)
    @valid_params = { password: @password,
                      confirm_password: @password,
                      organization_name: 'Test',
                      privacy: 'on' }
  end


  def test_refuses_invalid_invites
    registration = Registration.new(@expired_invite, @valid_params)
    refute registration.process!
    assert registration.errors.present?
  end

  def test_refuses_password_mismatch
    registration = Registration.new(@invite,
                                    @valid_params.merge(password: 'foo'))
    refute registration.process!
    assert registration.errors.present?   
  end

  def test_refuses_password_too_short
    p = {password: 'foo', confirm_password: 'foo'}
    registration = Registration.new(@invite,
                                    @valid_params.merge(p))
    refute registration.process!
    assert registration.errors.present?   
  end

  def test_refuses_organization_name_blank_with_power_user
    registration = Registration.new(@power_invite,
                                    @valid_params.merge(organization_name: ''))
    refute registration.process!
    assert registration.errors.present?      
  end

  def test_allows_organization_name_blank_with_normal_user
    registration = Registration.new(@invite,
                                    @valid_params.merge(organization_name: ''))
    assert registration.process!
    assert registration.errors.blank?
  end

  def test_organization_matches_invite
    registration = Registration.new(@invite, @valid_params)
    registration.process!
    assert_equal registration.organization.id, @invite.organization.id  
  end

  def test_registered_user_has_correct_roles
    registration = Registration.new(@invite, @valid_params)
    registration.process!
    @invite.roles.each do |role|
      assert registration.user.roles.include? role
    end
  end

  def test_power_invite_creates_organization
    registration = Registration.new(@power_invite, @valid_params)
    refute registration.organization
    registration.process!
    assert_equal registration.organization.name, @valid_params[:organization_name]
  end

  def test_power_invite_creates_owners_role_and_adds_user
    registration = Registration.new(@power_invite, @valid_params)
    registration.process!
    role = registration.organization.roles.first 
    assert_equal 'Administrators', role.name
    assert role.power_user?
    assert_equal registration.user.roles.first.id, role.id
  end

  def test_registration_marks_invite_as_complete  
    registration = Registration.new(@invite, @valid_params)
    registration.process!
    refute registration.invite.can_register?
  end

  def test_registration_cannot_occur_twice
    registration = Registration.new(@invite, @valid_params)
    assert registration.process!
    refute registration.process!
  end

  def test_registration_cannot_occur_unless_privacy_is_agreed
    registration = Registration.new(@power_invite,
                                    @valid_params.merge(privacy: ''))
    refute registration.process!
    assert registration.errors.present?      
  end

  def teardown
    DatabaseCleaner.clean  
  end

end