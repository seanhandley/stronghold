require 'test_helper'

class OrganizationUsageDecoratorTest < CleanTest
  def setup
    @organization = Organization.make!
    @organization_usage_decorator = OrganizationUsageDecorator.new(@organization)
  end

  def set_stub_values(params)
    @organization_usage_decorator.define_singleton_method(:resource) do |name, state|
      if state == 'used'
        {
          'VCPUs'   => params[:used_vcpus],
          'Memory'  => params[:used_memory],
          'Storage' => params[:used_storage]
        }[name]
      else
        {
          'VCPUs'   => params[:available_vcpus],
          'Memory'  => params[:available_ram],
          'Storage' => params[:available_storage]
        }[name]
      end
    end
  end

  def test_over_threshold_when_all_over
    set_stub_values(used_vcpus: 950, used_memory: 950, used_storage: 950,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert @organization_usage_decorator.over_threshold?
  end

  def test_over_threshold_when_vcpus_over
    set_stub_values(used_vcpus: 950, used_memory: 500, used_storage: 500,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert @organization_usage_decorator.over_threshold?
  end

  def test_over_threshold_when_memory_over
    set_stub_values(used_vcpus: 500, used_memory: 950, used_storage: 500,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert @organization_usage_decorator.over_threshold?
  end

  def test_over_threshold_when_storage_over
    set_stub_values(used_vcpus: 500, used_memory: 500, used_storage: 950,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert @organization_usage_decorator.over_threshold?
  end

  def test_not_over_threshold_when_none_over
    set_stub_values(used_vcpus: 500, used_memory: 500, used_storage: 500,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    refute @organization_usage_decorator.over_threshold?
  end

  def test_over_threshold_when_thresholed_is_ten
    OrganizationUsageDecorator.const_set('RESOURCE_THRESHOLD_PERCENTAGE', 10)
    set_stub_values(used_vcpus: 500, used_memory: 500, used_storage: 500,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert @organization_usage_decorator.over_threshold?
    OrganizationUsageDecorator.const_set('RESOURCE_THRESHOLD_PERCENTAGE', 90)
  end

  def test_threshold_message_when_all_over_threshhold
    message = "You are reaching your VCPUs, Memory, and Storage quota limit"
    set_stub_values(used_vcpus: 950, used_memory: 950, used_storage: 950,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert_equal message, @organization_usage_decorator.threshold_message
  end

  def test_threshold_message_when_vcpus_over_threshhold
    message = "You are reaching your VCPUs quota limit"
    set_stub_values(used_vcpus: 950, used_memory: 500, used_storage: 500,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert_equal message, @organization_usage_decorator.threshold_message
  end

  def test_threshold_message_when_memory_over_threshhold
    message = "You are reaching your Memory quota limit"
    set_stub_values(used_vcpus: 500, used_memory: 950, used_storage: 500,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert_equal message, @organization_usage_decorator.threshold_message
  end

  def test_threshold_message_when_storage_over_threshhold
    message = "You are reaching your Storage quota limit"
    set_stub_values(used_vcpus: 500, used_memory: 500, used_storage: 950,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert_equal message, @organization_usage_decorator.threshold_message
  end

  def test_threshold_message_when_storage_and_vcpus_over_threshhold
    message = "You are reaching your VCPUs and Storage quota limit"
    set_stub_values(used_vcpus: 950, used_memory: 500, used_storage: 950,
                    available_vcpus: 1000, available_ram: 1000,
                    available_storage: 1000)
    assert_equal message, @organization_usage_decorator.threshold_message
  end


end
