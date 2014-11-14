require 'test_helper'

class Billing::InstanceTest < Minitest::Test
  def setup
    @test_tenant = '1c483a77bbe44afcaf3a1d098a1a897f'
  end

  def test_thing
    VCR.use_cassette('instances_billable_hours') do
      end_time = Date.parse('2014-11-14 14:18:00')
      [1, 2, 3].each do |n|
        puts Billing::Instance.billable_hours(@test_tenant, 'm1.tiny', '', end_time - n.hours, end_time)
      end
    end
  end

  def teardown
    
  end

end