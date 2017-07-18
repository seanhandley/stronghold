require 'simplecov'
SimpleCov.start('rails') do
  add_group "Decorators", "app/decorators"
  add_group "Generators", "app/generators"
  add_group "Jobs", "app/jobs"
end

ENV["RAILS_ENV"] = "test"
$VERBOSE = nil

require File.expand_path("../../config/environment", __FILE__)

require "rails/test_help"
require "minitest/rails"
require 'minitest/pride'
require "faker"
require File.expand_path(File.dirname(__FILE__) + '/blueprints')
require 'database_cleaner'
require 'webmock/minitest'
require 'vcr'

require 'sidekiq/testing'
Sidekiq::Testing.fake!

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end

DatabaseCleaner.strategy = :truncation

class UserNoCallbacks < User
  def create_object   ; end
  def update_object   ; end
  def delete_object   ; end
  def update_password ; end
end

# Noops
Organization.redefine_method :create_salesforce_object do ; end
Organization.redefine_method :update_salesforce_object do ; end
Organization.redefine_method :can_sync_with_openstack  do ; end
Project.redefine_method      :create_openstack_object  do ; end
Project.redefine_method      :create_ceph_object       do ; end
Project.redefine_method      :delete_ceph_object       do ; end
User.redefine_method         :create_openstack_object  do ; end
User.redefine_method         :can_sync_with_openstack  do ; end
User.redefine_method         :update_password          do ; end
User.redefine_method         :generate_ec2_credentials do ; end
User.redefine_method         :subscribe_to_status_io   do ; end

module Billing
  class Instance < ApplicationRecord
    def metadata
      {}
    end
  end
end

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
end

def log_in(user)
  session[:user_id]         = user.id
  session[:created_at]      = Time.now.utc
  session[:token]           = SecureRandom.hex
  cookies.signed[:user_id]  = @user.id
  cookies.signed[:current_organization_id] ||= @user.primary_organization.id
  session[:organization_id] = @user.primary_organization.id
end

def assert_404(actions)
  actions.each do |verb, action, args|
    assert_raises(ActionController::RoutingError) do
      send verb, action, args
    end
  end
end

def json_response
  ActiveSupport::JSON.decode @response.body
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
end

module CleanupOurTests
  def teardown
    DatabaseCleaner.clean
    Authorization.current_user = nil
    Authorization.current_organization = nil
  end
end

class CleanTest < Minitest::Test
  include CleanupOurTests
end

class CleanControllerTest < ActionController::TestCase
  include CleanupOurTests
end
