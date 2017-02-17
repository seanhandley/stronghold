require_relative '../acceptance_test_helper'

class SupportTicketsTests < CapybaraTestCase
  
  def test_support_tickets_loads_ok
    visit(support_tickets_path)


    within('div.some-info') do
      assert has_content?('There are no tickets')
    end

  end
  
end