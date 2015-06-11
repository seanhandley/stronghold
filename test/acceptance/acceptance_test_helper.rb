require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "acceptance"
require File.expand_path("../../../config/environment", __FILE__)
require "rails/test_help"

require 'minitest'
require "minitest/rails/capybara"
require 'capybara/poltergeist'
require_relative '../support/alert_confirmer'

Recaptcha.configuration.skip_verify_env << 'acceptance'

# Uncomment to run tests on staging
# Capybara.run_server = false
# Capybara.app_host = CAPYBARA_CONFIG['url']

Capybara.server_port = 63346

## Uncomment this to help debug JS errors

# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app, js_errors: false)
# end

require File.expand_path(File.dirname(__FILE__) + '/../blueprints')
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

Capybara.default_driver = :poltergeist

for organization in Organization.all
  begin
    organization.destroy
  rescue StandardError => e
    STDERR.puts "Couldn't destroy org: #{organization.name}"
  end
end

DatabaseCleaner.clean

# seed
require 'rake'
Rake::Task.clear
Stronghold::Application.load_tasks
Rake::Task["db:seed"].invoke

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :inspector => true, :timeout => 60,
    phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any'])
end

# Capybara.javascript_driver = :poltergeist
Capybara.javascript_driver = :poltergeist

module LoggingIn
  include Capybara::DSL
  
  def login(username=nil, password=nil)
    u = username || User.first.email
    p = password || "12345678"
    visit('/sign_in')
    fill_in('inputEmail',    :with => u)
    fill_in('inputPassword', :with => p)
    click_button('Sign In')
  end

  def logout
    Capybara.reset_sessions!
  end     
end

Minitest.after_run do
  Organization.destroy_all rescue nil
  User.destroy_all rescue nil
  DatabaseCleaner.clean
end

class CapybaraTestCase < Minitest::Test
  include Rails.application.routes.url_helpers
  include Capybara::DSL
  include LoggingIn

  def setup
    login  
  end
  
  def teardown
    Capybara.reset_sessions!
  end
end
