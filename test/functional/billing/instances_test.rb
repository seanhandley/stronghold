require 'test_helper'

class InstancesTest < Minitest::Test
  def setup
    @test_tenant = Tenant.make!
    @first_sync = Billing::Sync.create(started_at:   Time.parse('2014-11-19 18:20:47'),
                                       completed_at: Time.parse('2014-11-19 18:20:47'))
    VCR.use_cassette('instance_sync') do
      Billing::Instances.sync!(Time.parse('2014-11-19 14:00:00'), Time.parse('2014-11-21 23:00:00'), @first_sync)
    end
  end

  def test_inactive_machines_dont_incur_charges
    VCR.use_cassette('check_inactives') do
      assert_equal 3, Billing::Instances.usage(@test_tenant.uuid, Time.parse('2014-11-21 14:00:00'), Time.parse('2014-11-21 15:00:00')).keys.count
      # All three instances were terminates before 15:00
      assert_equal 0, Billing::Instances.usage(@test_tenant.uuid, Time.parse('2014-11-21 15:00:00'), Time.parse('2014-11-21 15:30:00')).keys.count
    end
  end

  def test_machines_on_steady_incur_full_usage
    VCR.use_cassette('check_steady_ons') do
      usage = Billing::Instances.usage(@test_tenant.uuid, Time.parse('2014-11-21 16:10:00'), Time.parse('2014-11-21 16:15:00'))
      assert_equal 1, usage.keys.count
      measurement_1 = usage.values.first[:billable_seconds]
      usage = Billing::Instances.usage(@test_tenant.uuid, Time.parse('2014-11-21 16:10:00'), Time.parse('2014-11-21 16:15:30'))
      measurement_2 = usage.values.first[:billable_seconds]
      assert_equal 30, measurement_2 - measurement_1
    end
  end

  def teardown
    DatabaseCleaner.clean
  end

end