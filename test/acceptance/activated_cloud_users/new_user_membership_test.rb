require_relative '../acceptance_test_helper'

class NewUserMembershipTests < CapybaraTestCase

  def setup
    @organization1 = Organization.create(name: 'test-organization1')
    @organization2 = Organization.create(name: 'test-organization2')
    @user = User.create(organizations: [@organization1])
    @member_role = @organization2.roles.create! name: "foo"
    @admin_role = @organization2.roles.create! name: "bar", power_user: true
  end

  def test_new_membership
    @invite = Invite.create! organization_id: @organization2.id, email: @user.email, roles: [@member_role]
    visit("/membership/#{@invite.token}")
    sleep(5)
    click_link('Proceed')
    sleep(5)
    assert page.has_content?('Thank you for joining')
    click_link('Continue')
    sleep(5)
    assert page.has_content?('Welcome')
    select('test-organization1', :from => 'select-organization')
    sleep(5)
    page.has_content?('Account changed successfully.')
  end

  def test_new_membership_has_correct_roles
    @organization2.update_attributes(self_service: false)
    @invite = Invite.create! organization: @organization2, email: @user.email, roles: [@admin_role]
    visit("/membership/#{@invite.token}")
    sleep(5)
    click_link('Proceed')
    sleep(5)
    assert page.has_content?('Thank you for joining')
    click_link('Continue')
    sleep(5)

    assert find(:xpath, "//a[@href='#{support_roles_path}']")
  end

  def  test_new_membership_has_correct_projects
  end

  def test_can_delete_membership_for_a_user
  end
end
