require_relative '../acceptance_test_helper'

class FreshSignupTests < CapybaraTestCase

  def setup
    logout
  end
  
  def test_new_signup
    visit('/signup')
    fill_in('email', :with => 'test@test.com')
    click_button('Create Account')
    within('#sign-in') do
      assert has_content?('Thanks for signing up!')
    end
  end

  def test_new_signup_bad_email
    visit('/signup')
    fill_in('email', :with => 'endsean.ha@d')
    click_button('Create Account')
    within('#sign-in') do
      assert has_content?('Email is not a valid address')
    end
  end

  def test_new_signup_existing_email
    visit('/signup')
    fill_in('email', :with => User.first.email)
    click_button('Create Account')
    within('#sign-in') do
      assert has_content?('Email is already in use')
    end
  end
end