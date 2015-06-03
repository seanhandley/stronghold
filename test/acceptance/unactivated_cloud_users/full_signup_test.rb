require_relative '../acceptance_test_helper'

class FullSignupTests < CapybaraTestCase

  def setup
    logout
  end
  
  def test_full_signup
    visit('/signup')
    fill_in('email', :with => 'test@test.com')
    click_button('Create Account')
    within('#sign-in') do
      assert has_content?('Thanks for signing up!')
    end

    sleep(10)

    visit("/signup/#{Invite.last.token}")

    within('#sign-in') do
      assert has_content?('Set your password')
    end

    fill_in('password', :with => '12345678')
    click_button('Proceed')

    sleep(15)

    within('.page-body') do
      assert has_content?('Before we let you loose')
    end

    fill_in('idpc_input', :with => 'ID1 1QD')
    fill_in('address_line1', :with => '1 Street Street')
    fill_in('address_city', :with => 'Place')
    select('United Kingdom', :from => 'address_country')

    fill_in('card_number', :with => '4242424242424242')
    fill_in('cvc', :with => '123')
    fill_in('name', :with => 'MR FOO BAR')
    fill_in('expiry', :with => "03#{Date.today.year + 1}")

    page.save_screenshot('/Users/sean/Desktop/screenshot.png', :full => true)

    click_button('Activate →')

    sleep(20)

  end
end