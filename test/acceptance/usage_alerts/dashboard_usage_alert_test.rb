require_relative '../acceptance_test_helper'

module QuotaUsage
  def self.reset_value name, &block
    define_method name, &block
  end
end

class DashboardUsageAlert < CapybaraTestCase

  def test_no_message_when_under_threshold
    QuotaUsage.reset_value(:used_vcpus) { 50 }
    QuotaUsage.reset_value(:available_vcpus) { 1000 }

    QuotaUsage.reset_value(:used_ram) { 50 }
    QuotaUsage.reset_value(:available_ram) { 1000 }

    QuotaUsage.reset_value(:used_storage) { 50 }
    QuotaUsage.reset_value(:available_storage) { 1000 }

    visit('/')
    within('div#quota-limits') do
     refute page.has_content?('You are reaching your')
   end
  end

  def test_message_when_vcpus_and_memory_over_threshold
    QuotaUsage.reset_value(:used_vcpus) { 950 }
    QuotaUsage.reset_value(:available_vcpus) { 1000 }

    QuotaUsage.reset_value(:used_ram  ) { 950 }
    QuotaUsage.reset_value(:available_ram) { 1000 }

    QuotaUsage.reset_value(:used_storage) { 50 }
    QuotaUsage.reset_value(:available_storage) { 1000 }

    visit('/')
    within('div#quota-limits') do
      assert page.has_content?("You are reaching your VCPUs and Memory quota limit")
    end
  end

  def test_message_when_all_over_threshold
    QuotaUsage.reset_value(:used_vcpus) { 950 }
    QuotaUsage.reset_value(:available_vcpus) { 1000 }

    QuotaUsage.reset_value(:used_ram  ) { 950 }
    QuotaUsage.reset_value(:available_ram) { 1000 }

    QuotaUsage.reset_value(:used_storage) { 950 }
    QuotaUsage.reset_value(:available_storage) { 1000 }

    visit('/')
    within('div#quota-limits') do
      assert has_content?("You are reaching your VCPUs, Memory, and Storage quota limit")
    end
  end


  def test_alert_links_to_support_tickets
    QuotaUsage.reset_value(:used_vcpus) { 950 }
    QuotaUsage.reset_value(:available_vcpus) { 1000 }

    QuotaUsage.reset_value(:used_ram  ) { 950 }
    QuotaUsage.reset_value(:available_ram) { 1000 }

    QuotaUsage.reset_value(:used_storage) { 950 }
    QuotaUsage.reset_value(:available_storage) { 1000 }

    visit('/')
    within('div#quota-limits') do
      assert has_link?('alert-link')
    end
  end
end
