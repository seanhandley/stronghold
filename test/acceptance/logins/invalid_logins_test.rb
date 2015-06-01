require_relative '../acceptance_test_helper'

class InvalidLoginsTests < CapybaraTestCase
  
  def test_something
    skip and return
    save_and_open_screenshot
    within('.page-body') do
      assert has_content?('Welcome')
    end 
  end
  
end