require 'test_helper'

class Billing::InstancesTest < Minitest::Test
  def setup
    @test_tenant_id = '1c483a77bbe44afcaf3a1d098a1a897f'
    @first_sync = Billing::Sync.create(completed_at: DateTime.parse('2014-11-17 12:31:08'))
  end

  def test_sync
    VCR.use_cassette('instance_samples') do
      Billing::Instances.sync!
    end
  end


  def teardown
    
  end

end