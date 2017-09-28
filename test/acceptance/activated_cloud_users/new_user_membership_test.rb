require_relative '../acceptance_test_helper'

class NewUserMembershipTests < CapybaraTestCase

  def setup
    @organization = Organization.create(name: 'test-organization')
    @organization2 = Organization.create(name: 'test-organization2')
    @organization3 = Organization.create(name: 'test-organization3')
    @user = User.first
    @member_role = @organization.roles.create! name: "member"
    @admin_role = @organization2.roles.create! name: "admin", power_user: true
    @other_role = @organization3.roles.create! name: "other", power_user: true
  end

  def test_new_membership
    @admin_role.update_attributes(permissions: ['cloud.read', 'storage.read', 'roles.read'])
    @invite = Invite.create! organization_id: @organization.id, email: @user.email, roles: [@member_role]
    visit("/membership/#{@invite.token}")
    sleep(5)
    click_link('Proceed')
    sleep(5)
    assert page.has_content?('Thank you for joining')
    click_link('Continue')
    sleep(5)
    assert page.has_content?('Welcome')
    select('test-organization', :from => 'select-organization')
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
    select('test-organization2', :from => 'select-organization')
    sleep(5)
    assert find(:xpath, "//a[@href='#{support_roles_path}']")
    assert find(:xpath, "//a[@href='#{support_tickets_path}']")
  end

  def  test_new_membership_has_correct_projects
    @organization3.update_attributes(self_service: false)
    @organization3.products << Product.find_by_name('Compute')
    @invite = Invite.create! organization: @organization3,
                             email: @user.email,
                             roles: [@other_role],
                             project_ids: [@organization3.primary_project.id]
    visit("/membership/#{@invite.token}")
    sleep(5)
    click_link('Proceed')
    sleep(5)
    assert page.has_content?('Thank you for joining')
    click_link('Continue')
    sleep(5)
    select('test-organization3', :from => 'select-organization')
    sleep(5)
    visit(support_projects_path)
    assert page.has_content?("#{@organization3.primary_project.name}")
  end
end
