require_relative '../acceptance_test_helper'

class UserMenuTests < CapybaraTestCase
  
  def test_user_menu_contents
    visit('/')
    find('button#user-menu').click

    sleep(2)

    using_wait_time 10 do
      find(:xpath, "//a[@href='#{support_profile_path}']")
      assert find(:xpath, "//a[@href='#{support_profile_path}']")
      assert find(:xpath, "//a[@href='#{support_edit_organization_path}']")
      assert find(:xpath, "//a[@href='#{support_audits_path}']")
      assert find(:xpath, "//a[@href='#{signout_path}']")
    end
  end

  def test_user_can_logout
    visit('/')
    
    find('button#user-menu').click

    AlertConfirmer.accept_confirm_from do
      find(:xpath, "//a[@href='#{signout_path}']").click
    end

    sleep(2)

    using_wait_time 10 do
      within('div#sign-in') do
        assert has_content?('Sign In')
      end
    end
    
  end
  
end