require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require File.expand_path(File.dirname(__FILE__) + '/blueprints')
require 'database_cleaner'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end

OPENSTACK_ARGS[:openstack_api_key]  = 'foo' unless OPENSTACK_ARGS[:openstack_api_key]
OPENSTACK_ARGS[:openstack_username] = 'bar' unless OPENSTACK_ARGS[:openstack_username]

DatabaseCleaner.strategy = :truncation

class UserNoCallbacks < User
  skip_callback :create, :after, :create_object
  skip_callback :update, :after, :update_object
  skip_callback :destroy, :after, :delete_object
  skip_callback :save, :after, :update_password
end

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end