require_relative '../acceptance_test_helper'

class CloudProjectTests < CapybaraTestCase

  def setup
    login("capybara@test.com", '12345678')
    @organization = Organization.find_by_name 'capybara'
  end

  def set_project_quota(projects)
    @organization.update_attributes(projects_limit: projects)
  end

  def test_user_can_create_new_project
    set_project_quota(2)
    visit(support_projects_path)
    sleep(10)

    page.has_content?('New Project')
    click_link('New Project')
    sleep(1)

    within('.modal-content') do
      fill_in('project_name', :with => 'TestingNewProject')
      click_button('Add')
    end
    sleep(1)

    page.has_content?('TestingNewProject')
  end

  def test_user_cannot_create_project_if_limited_to_1
    visit(support_projects_path)
    sleep(10)

    page.has_content?('New Project')
    click_link('New Project')
    sleep(1)

    within('.modal-content') do
      fill_in('project_name', :with => 'TestingNewProject')
      click_button('Add')
    end
    sleep(1)

    page.has_content?("This account's limits only permit 1 project")
  end

  def test_user_can_edit_projects
    visit(support_projects_path)
    sleep(10)

    page.has_content?('Edit')
    click_link('Edit')
    sleep(1)

    within('.modal-content') do
      fill_in('project_name', :with => 'TestingEditProject')
      click_button('Save')
    end
    sleep(1)

    page.has_content?('TestingEditProject')
  end

  def test_user_can_remove_project
    set_project_quota(4)
    ["foo", "bar"].each do |n|
      @organization.projects.create! name: n
    end
    @project = Project.last

    visit(support_projects_path)
    sleep(10)

    AlertConfirmer.accept_confirm_from do
      click_link("removeProjectBtn#{@project.id}")
    end
    sleep(1)

    page.has_content?('Project removed successfully')
    2.times { Project.last.destroy }
  end

  def test_user_cannot_remove_primary_project
    visit(support_projects_path)
    sleep(10)

    page.has_no_content?('Remove')
  end

  def teardown
    Capybara.reset_sessions!
  end

end
