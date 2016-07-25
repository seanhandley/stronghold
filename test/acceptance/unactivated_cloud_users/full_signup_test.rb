require_relative '../acceptance_test_helper'

class FullSignupTests < CapybaraTestCase

  def setup
    logout
  end

  def test_full_signup
    Starburst::Announcement.destroy_all
    visit('/signup')
    fill_in('email', :with => 'test@test.com')
    click_button('Create Account')
    within('#sign-in') do
      assert has_content?('Thanks for signing up!')
    end

    sleep(10)

    visit("/signup/#{Invite.find_by_email('test@test.com').token}")

    within('#sign-in') do
      assert has_content?('Set your password')
    end

    fill_in('password', :with => '12345678')
    click_button('Proceed')

    sleep(15)

    within('.page-body') do
      assert has_content?('Before we let you loose')
    end

    within('.top-menu') do
      assert page.has_no_xpath?("//a[@href='#{support_roles_path}']")
      assert find(:xpath, "//a[@href='#{activate_path}']")
      assert find(:xpath, "//a[@href='#{support_usage_path}']")
      assert find(:xpath, "//a[@href='#{support_tickets_path}/']")
    end

    fill_in('idpc_input', :with => 'ID1 1QD')
    fill_in('address_line1', :with => '1 Street Street')
    fill_in('address_city', :with => 'Place')
    select('United Kingdom', :from => 'address_country')

    4.times {find_field('card_number').native.send_key('4242')}
    find_field('expiry').native.send_key '05'
    find_field('expiry').native.send_key (Date.today.year + 1).to_s
    fill_in('name', :with => 'MR FOO BAR')
    find_field('cvc').native.send_key '123'

    find('input[type="submit"]').click

    # page.driver.debug

    sleep(60)

    # save_screenshot('/Users/sean/Desktop/screen.png', :full => true)

    within('.page-body') do
      assert has_content?('Last week, you spent')
      assert has_content?('OpenStack Dashboard')
      assert has_content?('API Details')
    end

    within('.top-menu') do
      assert page.has_no_xpath?("//a[@href='#{activate_path}']")
      assert find(:xpath, "//a[@href='#{support_usage_path}']")
      assert find(:xpath, "//a[@href='#{support_tickets_path}/']")
      assert find(:xpath, "//a[@href='#{support_roles_path}']")
    end

  end
end
