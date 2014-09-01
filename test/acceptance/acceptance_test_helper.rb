require 'capybara'
require 'test/unit'
require 'yaml'
require 'capybara/poltergeist'

CAPYBARA_CONFIG = YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), "../../config/capybara.yml")))

Capybara.run_server = false

## Uncomment this to help debug JS errors

# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app, js_errors: false)
# end

Capybara.default_driver = :poltergeist
Capybara.app_host = CAPYBARA_CONFIG['url']

module LoggingIn
  include Capybara::DSL
  
  def login
    visit('/sign_in')
    fill_in('inputEmail',    :with => CAPYBARA_CONFIG['username'])
    fill_in('inputPassword', :with => ENV["CAPYBARA_PASSWORD"])
    click_button('Sign In')
  end      
end

class CapybaraTestCase < Test::Unit::TestCase
  include Capybara::DSL
  include LoggingIn

  def setup
    login  
  end
  
  def teardown
    Capybara.reset_sessions!
  end
end

module WaitForSync
  include Capybara::DSL
  
  def wait_for_sync
    sleep(2)
    until find(:xpath, "//span[contains(@class, 'sync-status')]").text == 'SYNCED' do
      sleep(1)
    end
    sleep(2)
  end
end
