require 'test_helper'

class TestUser < CleanTest
  def setup
    @user_with_password = User.make
    @user_without_password = User.make(:without_password)
  end

  def test_valid_by_default
    assert @user_with_password.valid?
  end

  def test_user_invalid_without_password
    refute @user_without_password.valid?
  end

  def test_user_password_confirmation_must_match
    @user_with_password.password = "foo"
    @user_with_password.password_confirmation = "bar"
    refute @user_without_password.valid?
    @user_without_password.update_attributes(password: 'foo', password_confirmation: 'foo')
  end

end