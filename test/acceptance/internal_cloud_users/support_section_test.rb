require_relative '../acceptance_test_helper'

class SupportSectionTests < CapybaraTestCase

  def setup
    cg = CustomerGenerator.new(organization_name: 'capybara', email: "capybara@test.com",
      extra_projects: "", organization: { product_ids: Product.all.map{|p| p.id.to_s}})
    cg.generate!
    rg = RegistrationGenerator.new(Invite.last, password: '12345678')
    rg.generate!

    Organization.last.update_attributes reporting_code: 'capybara'

    login("capybara@test.com", '12345678')
  end
  
  def test_user_can_create_new_ticket
    visit(support_tickets_path)

    sleep(10)

    page.has_content?('Create a new ticket')

    find(:xpath, "//a[@ng-click='ticketDialogShow()']").click
    sleep(1)

    select('Staging', :from => 'new_ticket_department')
    sleep(1)
    fill_in('new_ticket_title', :with => 'Test Ticket')
    fill_in('new_ticket_description', :with => 'Test Ticket')
    find(:xpath, "//button[@ng-click='ticketDialogSubmit()']").click
    visit(support_tickets_path)
    sleep(10)
    page.has_content?('Test Ticket')
    # save_screenshot('/Users/sean/Desktop/screen.png', :full => true)
  end

  def teardown
    TicketAdapter.all.map(&:reference).each{|ref| SIRPORTLY.ticket(ref).destroy }
  end
  
end