require_relative '../acceptance_test_helper'

class TemporaryAssignmentTests < CapybaraTestCase

  def setup
    @user = User.find_by_email('capybara@test.com')
    @organization = Organization.find_by_name 'capybara'
    @organization.update_attributes reference: 'datacentred'
    @user.roles.first.update_attributes power_user: true
    login
  end

  def test_satff_can_create_temporary_membership
    @organization2 = Organization.create(name: 'test-organization2')
    @organization2.update_attributes(self_service: false)
    visit admin_customer_path(@organization2)
    find('input#create-org-membership').click
    page.has_content?('You have added yourself to this account.')
    page.has_content?('Remaining time: about 4 hours')
    select('test-organization2', :from => 'select-organization')
    sleep(5)
    page.has_content?('Account changed successfully.')

    visit('/')
    page.has_content?('Welcome')
  end

  def test_user_cant_navigate_expired_membership
    @organization3 = Organization.create(name: 'test-organization3')
    @organization3.update_attributes(self_service: false)
    visit admin_customer_path(@organization3)
    find('input#create-org-membership').click

    select('test-organization3', :from => 'select-organization')
    sleep(5)
    page.has_content?('Account changed successfully.')

    Timecop.freeze(Time.now + 5.hours) do
      visit('/')
      page.has_content?('Your temporary mermbership to Test-Organization3 has expired.')
    end
  end
end
