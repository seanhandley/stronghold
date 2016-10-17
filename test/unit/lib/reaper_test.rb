require 'test_helper'

class TestReaper < CleanTest

  def setup
    @organization = Organization.make!
    @sync = { period_from: Time.now - 4.hours, period_to: Time.now - 3.hours,
              started_at: Time.now - 61.minutes, completed_at: Time.now - 1.hour}
    Billing::Sync.create! @sync
    @ips = [
             {ip_id: "24ef48cf-6999-42ef-8533-e5eb2835e00f",
              project_id: "06a9a90c60074cdeae5f7fdd0048d9ac",
              address: "172.24.4.214",
              ip_type: 'ip.floating', recorded_at: Time.now - 7.days,
              billing_sync: Billing::Sync.first},
             {ip_id: "06ff91df-3c1c-46ae-b52a-f40d900b270c",
              project_id: "0604abc562db4a3a8d4518025fca5822",
              address: "172.24.4.216",
              ip_type: 'ip.floating', recorded_at: Time.now - 7.days,
              billing_sync: Billing::Sync.first}
           ]
    @ips.each{|ip| Billing::Ip.create! ip}
    @instance_id = "a458bea2-a9c9-468b-b788-ee1a943b2a3d"
    @reaper = Reaper.new
  end

  def test_stuck_in_a_project
    VCR.use_cassette("reaper_stuck_in_a_project") do
      assert_equal 1, @reaper.stuck_in_a_project.count
      assert_equal @ips[0][:address],    @reaper.stuck_in_a_project.first[:public_ip]
      assert_equal @ips[0][:project_id], @reaper.stuck_in_a_project.first[:tenant_id]
      assert_equal @ips[0][:ip_id],      @reaper.stuck_in_a_project.first[:ip_id]
    end
  end

  def test_stuck_in_an_instance
    VCR.use_cassette("reaper_stuck_in_an_instance") do
      assert_equal 1, @reaper.stuck_in_an_instance.count
      assert_equal @ips[1][:address],    @reaper.stuck_in_an_instance.first.public_ip
      assert_equal @ips[1][:project_id], @reaper.stuck_in_an_instance.first.tenant_id
      assert_equal @instance_id,         @reaper.stuck_in_an_instance.first.instance_id
    end
  end

  def test_dormant_routers
    VCR.use_cassette("reaper_dormant_routers") do
      assert_equal 2, @reaper.dormant_routers.count
    end
  end

  def test_reap_dry_run
    VCR.use_cassette("reaper_reap_dry_run") do
      mock = Minitest::Mock.new
      messages = ["Transitioning #{@organization.name} (#{@organization.reporting_code}) to dormant state",
                  "Removed unused IP 172.24.4.214 from tenant 06a9a90c60074cdeae5f7fdd0048d9ac"]
      messages.each {|m| mock.expect(:info, nil, [m])}
      @reaper.stub(:logger, mock) do
        Project.stub(:find_by_uuid, OpenStruct.new(organization: @organization)) do
          @reaper.reap
        end
      end
    end
  end

end
