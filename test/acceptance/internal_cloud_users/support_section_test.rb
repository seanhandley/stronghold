require_relative '../acceptance_test_helper'

class SupportSectionTests < CapybaraTestCase
  
  def test_user_can_create_new_ticket
    visit(support_tickets_path)

    sleep(10)

    page.has_content?('Create a new ticket')
    find(:xpath, "//a[@ng-click='ticketDialogShow()']").click
    sleep(1)
    select('Staging', :from => 'new_ticket_department')
    sleep(1)
    fill_in('new_ticket_title', :with => 'Test')
    fill_in('new_ticket_description', :with => 'Test')
    # find(:xpath, "//button[@ng-click='ticketDialogSubmit()']").click
    # visit(support_tickets_path)

    # sleep(10)
    # save_screenshot('/Users/sean/Desktop/screen.png', :full => true)
  end
  
end