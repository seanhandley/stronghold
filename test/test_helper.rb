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
  Billing::InstanceFlavor.create(id: 1, flavor_id: '1', name: 'm1.tiny', ram: 512, disk: 1, vcpus: 1)
  Billing::InstanceFlavor.create(id: 2, flavor_id: '2', name: 'm1.small', ram: 2048, disk: 20, vcpus: 1)
  Billing::InstanceFlavor.create(id: 3, flavor_id: '3', name: 'm1.medium', ram: 4096, disk: 40, vcpus: 2)
  Billing::InstanceFlavor.create(id: 4, flavor_id: '5', name: 'm1.xlarge', ram: 16384, disk: 160, vcpus: 8)
  Billing::InstanceFlavor.create(id: 5, flavor_id: '4', name: 'm1.large', ram: 8192, disk: 80, vcpus: 4)

  Billing::InstanceFlavor.create(id: 6, flavor_id: 'ede87d00-b2a7-4b74-acf7-1490a6c29f22', name: 'm1.xlarge', ram: 16384, disk: 80, vcpus: 8)
  Billing::InstanceFlavor.create(id: 7, flavor_id: 'f0577618-9125-4948-b450-474e225bbc4c', name: 'dc1.1x1', ram: 1024, disk: 40, vcpus: 1)
  Billing::InstanceFlavor.create(id: 8, flavor_id: '8f4b7ae1-b8c2-431f-bb0c-362a5ece0381', name: 'dc1.2x4', ram: 4096, disk: 80, vcpus: 2)
  Billing::InstanceFlavor.create(id: 9, flavor_id: 'bf6dbcab-f0a5-49d7-b427-0ee09cc5f583', name: 'dc1.2x2', ram: 2048, disk: 80, vcpus: 2)
  Billing::InstanceFlavor.create(id: 10, flavor_id: '78d43ae0-7c98-48d2-9adc-90e8f8f6fe99', name: 'dc1.1x0', ram: 512, disk: 10, vcpus: 1)
  Billing::InstanceFlavor.create(id: 11, flavor_id: 'b671216b-1c68-4765-b752-0e8e6b6d015f', name: 'dc1.1x2', ram: 2048, disk: 40, vcpus: 1)
  Billing::InstanceFlavor.create(id: 12, flavor_id: '7e1d9f77-acdf-41bb-a5e8-572ee153d21f', name: 'dc1.4x8', ram: 8192, disk: 120, vcpus: 4)
  Billing::InstanceFlavor.create(id: 13, flavor_id: '05a9e6d1-d29f-4e98-9eab-51c9a6beed44', name: 'dc1.1x2.20', ram: 2048, disk: 20, vcpus: 1)
  Billing::InstanceFlavor.create(id: 14, flavor_id: '196235bc-7ca5-4085-ac81-7e0242bda3f9', name: 'dc1.2x4.40', ram: 4096, disk: 40, vcpus: 2)
  Billing::InstanceFlavor.create(id: 15, flavor_id: 'c4b193d2-f331-4250-9b15-bbfde97c462a', name: 'dc1.2x2.40', ram: 2048, disk: 40, vcpus: 2)
  Billing::InstanceFlavor.create(id: 16, flavor_id: 'af2a80fe-ccad-43df-8cae-6418da948467', name: 'dc1.8x16', ram: 16384, disk: 80, vcpus: 8)

  rates = [[1, 'x86_64', 0.0089],
          [2, 'x86_64', 0.0177],
          [3, 'x86_64', 0.0695],
          [4, 'x86_64', 0.2817],
          [5, 'x86_64', 0.1391],
          [6, 'x86_64', 0.2817],
          [7, 'x86_64', 0.2817],
          [8, 'x86_64', 0.0177],
          [9, 'x86_64', 0.0695],
          [10, 'x86_64', 0.0353],
          [11, 'x86_64', 0.0089],
          [12, 'x86_64', 0.0348],
          [13, 'x86_64', 0.1391],
          [14, 'x86_64', 0.1375],
          [15, 'x86_64', 0.1375],
          [16, 'x86_64', 0.2817],
          [17, 'x86_64', 0.2817],
          [18, 'x86_64', 0.0348],
          [19, 'x86_64', 0.0177],
          [20, 'x86_64', 0.0177],
          [21, 'x86_64', 0.0348],
          [22, 'x86_64', 0.0695],
          [23, 'x86_64', 0.275],
          [24, 'x86_64', 0.0353],
          [25, 'x86_64', 0.5634],
          [26, 'x86_64', 0.525],
          [27, 'x86_64', 0.2817],
          [28, 'x86_64', 0.0353],
          [29, 'aarch64', 0.139],
          [30, 'aarch64', 0.0706],
          [31, 'aarch64', 0.2782],
          [32, 'aarch64', 0.55],
          [33, 'aarch64', 0.0354],
          [34, 'aarch64', 0.0696],
          [35, 'x86_64', 0.0354],
          [37, 'x86_64', 0.0353],
          [38, 'aarch64', 0.275],
          [39, 'aarch64', 1.05],
          [40, 'x86_64', 0.525],
          [9, 'aarch64', 0.139],
          [10, 'aarch64', 0.0706],
          [16, 'aarch64', 0.2782],
          [23, 'aarch64', 0.55],
          [8, 'aarch64', 0.0354],
          [12, 'aarch64', 0.0696],
          [14, 'aarch64', 0.275]]
  rates.each do |rate|
    Billing::Rate.create(flavor_id: rate[0], arch: rate[1], rate: rate[2])
  end
end
