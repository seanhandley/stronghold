require_relative '../acceptance_test_helper'

class DashboardUsageAlert < CapybaraTestCase

  def test_no_message_when_under_threshold
    visit('/')
    sleep 1
    within('div#quota-limits') do
      @alerts_message = ""
      refute page.has_content?('You are reaching your')
      save_screenshot('/Users/eugenia/Desktop/screen1.png', :full => true)
    end
  end

  def test_message_when_all_over_threshold
    visit('/')
    sleep 1
    within('div#quota-limits') do
      @alerts_message = "You are reaching your Vcpus, Memory, and Storage quota limit"
      assert page.has_content?("You are reaching your Vcpus, Memory, and Storage quota limit")
      save_screenshot('/Users/eugenia/Desktop/screen2.png', :full => true)
    end

  end

  def test_alert_links_to_support_tickets
    visit('/')
    sleep 1
    within('div#quota-limits') do
      @alerts_message = "You are reaching your Vcpus, Memory, and Storage quota limit"
      assert has_link?('alert-link')
    end
  end

end
