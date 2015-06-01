ENV["RAILS_ENV"] = "acceptance"
require File.expand_path("../../../config/environment", __FILE__)
require "rails/test_help"

require "minitest/rails/capybara"
require 'capybara/poltergeist'

VCR.configure do |c|
  c.ignore_localhost = true
end

# Uncomment to run tests on staging
# Capybara.run_server = false
# Capybara.app_host = CAPYBARA_CONFIG['url']

## Uncomment this to help debug JS errors

# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app, js_errors: false)
# end

require File.expand_path(File.dirname(__FILE__) + '/../blueprints')
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

Capybara.default_driver = :poltergeist

module LoggingIn
  include Capybara::DSL
  
  def login
    @user = User.make!
    visit('/sign_in')
    fill_in('inputEmail',    :with => @user.email)
    fill_in('inputPassword', :with => "UpperLower123")
    click_button('Sign In')
  end

  def logout
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end      
end

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include LoggingIn

  def setup
    WebMock.allow_net_connect!
    login  
  end
  
  def teardown
    WebMock.disable_net_connect!
    Capybara.reset_sessions!
  end
end
