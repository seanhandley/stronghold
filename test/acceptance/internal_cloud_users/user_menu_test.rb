require_relative '../acceptance_test_helper'

class UserMenuTests < CapybaraTestCase
  
  def test_user_menu_contents
    visit('/')
    
    find('button#user-menu').click

    sleep(2)
    page.has_content?('My Profile')
    page.has_content?('My Account')
    page.has_content?('Audit Log')
    page.has_content?('Limits')
  end

  def test_user_can_logout
    visit('/')

    find('button#user-menu').click

    AlertConfirmer.accept_confirm_from do
      find(:xpath, "//a[@href='#{signout_path}']").click
    end

    sleep(2)

    within('div#sign-in') do
      assert has_content?('Sign In')
    end
    
  end
  
end