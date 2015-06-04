require_relative '../acceptance_test_helper'

class ActivatedCloudUserMenuTests < CapybaraTestCase
  
  # def test_user_menu_contents
  #   logout
  #   login(user, '12345678')
  #   visit('/')
  #   find('button#user-menu').click

  #   sleep(1)

  #   within('ul.dropdown-menu') do
  #     assert find(:xpath, "//a[@href='#{support_profile_path}']")
  #     assert find(:xpath, "//a[@href='#{support_edit_organization_path}']")
  #     assert find(:xpath, "//a[@href='#{support_manage_cards_path}']")
  #     assert find(:xpath, "//a[@href='#{support_audits_path}']")
  #     assert find(:xpath, "//a[@href='#{session_path(User.find_by_email(user))}']")
  #   end
  # end

  # def user
  #   @user ||= Proc.new do
  #     Authorization.current_user = nil
  #     rand = (0...8).map { ('a'..'z').to_a[rand(26)] }.join.downcase
  #     cs = CustomerSignup.new(email: "#{rand}@test.com")
  #     cs.save!
  #     cg = CustomerSignupGenerator.new(cs)
  #     cg.generate!
  #     rg = RegistrationGenerator.new(Invite.last, password: '12345678')
  #     rg.generate!
  #     "#{rand}@test.com"
  #   end.call
  # end
  
end