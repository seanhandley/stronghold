require 'test_helper'

class Billing::InstanceTest < Minitest::Test
  def setup
    @test_tenant_id = '1c483a77bbe44afcaf3a1d098a1a897f'
  end

  def test_thing
    VCR.use_cassette('instance_samples') do
      end_time = DateTime.parse('2014-11-18 12:05:00')
      samples = Billing::Instance.samples(@test_tenant_id, end_time - 3.hours, end_time)
      assert_equal 3, samples.keys.count
      assert_equal 34, samples.values[0].count
      assert_equal 6, samples.values[1].count
      assert_equal 10, samples.values[2].count
    end
  end

  def teardown
    
  end

end