require_relative '../acceptance_test_helper'

class DashboardTests < CapybaraTestCase

  def setup
    login
  end

  def test_dashboard
    visit('/')
    sleep(1)
    within('.page-body') do
      assert has_content?('Last week, you spent')
      assert has_content?('OpenStack Dashboard')
      assert has_content?('API Details')
    end

    within('#sidebar-list') do
      assert page.has_no_xpath?("//a[@href='#{activate_path}']")
      assert find(:xpath, "//a[@href='#{support_profile_path}']")
      assert find(:xpath, "//a[@href='#{support_edit_organization_path}']")
      assert find(:xpath, "//a[@href='#{support_quotas_path}']")
      assert find(:xpath, "//a[@href='#{support_tickets_path}']")
      # assert find(:xpath, "//a[@href='#{support_usage_path}']")
      assert find(:xpath, "//a[@href='#{support_projects_path}']")
    end

    within('.main-content-container') do
      assert has_content?('Overview')
      assert has_content?('Compute')
      assert has_content?('Volume')
      assert has_content?('Network')
      assert has_content?('Cloud Projects')
    end
  end
end
