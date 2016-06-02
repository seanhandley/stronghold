require 'test_helper'

class InstancesTest < Minitest::Test
  def setup
    @auth = OPENSTACK_ARGS[:openstack_auth_url]
    OPENSTACK_ARGS[:openstack_auth_url] = "https://compute.datacentred.io:5000/v2.0/tokens"
    @test_project = Project.make!
    @first_sync = Billing::Sync.create(started_at:   Time.parse('2014-11-19 18:20:47'),
                                       completed_at: Time.parse('2014-11-19 18:20:47'))
    load_instance_flavors
    VCR.use_cassette('instance_sync') do
      Billing::Instances.sync!(Time.parse('2014-11-19 14:00:00'), Time.parse('2014-11-21 23:00:00'), @first_sync)
    end
  end

  def test_inactive_machines_dont_incur_charges
    assert_equal 3, Billing::Instances.usage(@test_project.uuid, Time.parse('2014-11-21 14:00:00'), Time.parse('2014-11-21 15:00:00')).count
    # All three instances were terminates before 15:00
    assert_equal 0, Billing::Instances.usage(@test_project.uuid, Time.parse('2014-11-21 15:00:00'), Time.parse('2014-11-21 15:30:00')).count
  end

  def test_machines_on_steady_incur_full_usage
    usage = Billing::Instances.usage(@test_project.uuid, Time.parse('2014-11-21 16:10:00'), Time.parse('2014-11-21 16:15:00'))
    assert_equal 1, usage.count
    measurement_1 = usage.first[:billable_hours]
    usage = Billing::Instances.usage(@test_project.uuid, Time.parse('2014-11-21 16:10:00'), Time.parse('2014-11-21 17:15:00'))
    measurement_2 = usage.first[:billable_hours]
    assert_equal 1, measurement_2 - measurement_1
  end

  def teardown
    OPENSTACK_ARGS[:openstack_auth_url] = @auth
    DatabaseCleaner.clean
  end

end