require 'test_helper'

class MockServers
  def get(instance_id); nil; end
end

class TestInstancesResize < Minitest::Test
  def setup
    @from = Time.parse("2015-07-23 08:00:00")
    @to = Time.parse("2015-07-23 18:00:00")
    @tenant = Tenant.make!(name: 'datacentred', uuid: 'ed4431814d0a40dc8f10f5ac046267e9')
    @events = JSON.parse(File.read(File.expand_path("../../../../fixtures/dumps/resize_instance.json", __FILE__)))
    @servers_mock = OpenStruct.new(servers: MockServers.new)
    load_instance_flavors
  end

  def test_calculation_of_cost
    # Instance starts as 2x2 (billed at 0.0353)
    # and becomes 8x16 (billed at 0.2817)  
    Billing.stub(:fetch_samples, @events) do
      Fog::Compute.stub(:new, @servers_mock) do
        Billing::Instances.sync!(@from, @to, Billing::Sync.create(started_at: Time.now))
        instance = Billing::Instance.find_by_instance_id("b246c075-36d8-45ee-a8f5-a44c15158dd9")
        assert_equal 0.5989945815555554, Billing::Instances.cost(instance, @from, @to)
      end
    end
  end

  def teardown
    DatabaseCleaner.clean
  end

end
