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

def load_instance_flavors
  Billing::InstanceFlavor.create(flavor_id: '1', name: 'm1.tiny', ram: 512, disk: 1, vcpus: 1)
  Billing::InstanceFlavor.create(flavor_id: '2', name: 'm1.small', ram: 2048, disk: 20, vcpus: 1)
  Billing::InstanceFlavor.create(flavor_id: '3', name: 'm1.medium', ram: 4096, disk: 40, vcpus: 2)
  Billing::InstanceFlavor.create(flavor_id: '5', name: 'm1.xlarge', ram: 16384, disk: 160, vcpus: 8)
  Billing::InstanceFlavor.create(flavor_id: '4', name: 'm1.large', ram: 8192, disk: 80, vcpus: 4)

  Billing::InstanceFlavor.create(flavor_id: 'ede87d00-b2a7-4b74-acf7-1490a6c29f22', name: 'm1.xlarge', ram: 16384, disk: 80, vcpus: 8)
  Billing::InstanceFlavor.create(flavor_id: 'c3ac228b-d74e-4e22-88a2-773d86b96469', name: 'dc1.8x16', ram: 16384, disk: 120, vcpus: 8)
  Billing::InstanceFlavor.create(flavor_id: 'f0577618-9125-4948-b450-474e225bbc4c', name: 'dc1.1x1', ram: 1024, disk: 40, vcpus: 1)
  Billing::InstanceFlavor.create(flavor_id: '8f4b7ae1-b8c2-431f-bb0c-362a5ece0381', name: 'dc1.2x4', ram: 4096, disk: 80, vcpus: 2)
  Billing::InstanceFlavor.create(flavor_id: 'bf6dbcab-f0a5-49d7-b427-0ee09cc5f583', name: 'dc1.2x2', ram: 2048, disk: 80, vcpus: 2)
  Billing::InstanceFlavor.create(flavor_id: '78d43ae0-7c98-48d2-9adc-90e8f8f6fe99', name: 'dc1.1x0', ram: 512, disk: 10, vcpus: 1)
  Billing::InstanceFlavor.create(flavor_id: 'b671216b-1c68-4765-b752-0e8e6b6d015f', name: 'dc1.1x2', ram: 2048, disk: 40, vcpus: 1)
  Billing::InstanceFlavor.create(flavor_id: '7e1d9f77-acdf-41bb-a5e8-572ee153d21f', name: 'dc1.4x8', ram: 8192, disk: 120, vcpus: 4)

  ["aarch64", "x86_64"].each do |arch|
    Billing::InstanceFlavor.all.each do |flavor|
      Billing::Rate.create(flavor_id: flavor.id, arch: arch, rate: 0.5)
    end
  end
end
