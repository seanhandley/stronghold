require 'test_helper'

class Billing::InstancesTest < Minitest::Test
  def setup
    @test_tenant_id = '1c483a77bbe44afcaf3a1d098a1a897f'
  end

  def test_sync
    VCR.use_cassette('instance_samples') do
      Billing::Instances.sync!
    end
  end


  def teardown
    
  end

end