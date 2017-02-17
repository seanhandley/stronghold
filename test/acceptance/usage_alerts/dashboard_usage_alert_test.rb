require_relative '../acceptance_test_helper'

module QuotaUsage
  def self.reset_value name, &block
    define_method name, &block
  end
end

class DashboardUsageAlert < CapybaraTestCase

  def reset_quota_usages(params)
    params.each{|k,v| QuotaUsage.reset_value(k) { v } }
  end

  def test_no_message_when_under_threshold
    reset_quota_usages used_vcpus: 50, available_vcpus: 1000, used_ram: 50, available_ram: 1000, used_storage: 50, available_storage: 1000

    visit('/')
    sleep(5)

    within('div#quota-limits') do
     refute page.has_content?('You are reaching your')
   end
  end

  def test_message_when_vcpus_and_memory_over_threshold
    reset_quota_usages used_vcpus: 950, available_vcpus: 1000, used_ram: 950, available_ram: 1000, used_storage: 50, available_storage: 1000

    visit('/')
    sleep(5)

    within('div#quota-limits') do
      assert page.has_content?("You are reaching your VCPUs and Memory quota limit")
    end
  end

  def test_message_when_all_over_threshold
    reset_quota_usages used_vcpus: 950, available_vcpus: 1000, used_ram: 950, available_ram: 1000, used_storage: 950, available_storage: 1000

    visit('/')
    sleep(5)
    within('div#quota-limits') do
      assert has_content?("You are reaching your VCPUs, Memory, and Storage quota limit")
    end
  end


  def test_alert_links_to_support_tickets
    reset_quota_usages used_vcpus: 950, available_vcpus: 1000, used_ram: 950, available_ram: 1000, used_storage: 950, available_storage: 1000

    visit('/')
    sleep(5)
    within('div#quota-limits') do
      assert has_link?('alert-link')
    end
  end
end
