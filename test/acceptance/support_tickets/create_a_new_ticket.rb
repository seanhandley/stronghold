require_relative '../acceptance_test_helper'

class CreateNewTicketTests < CapybaraTestCase
  include WaitForSync
  
  def test_something
    visit("/support/tickets")
    sleep(10)
    within("#tickets-container") do
      assert has_content?('Select a ticket')
    end
  end
  
end