require 'test_helper'

class TestModel
  include OpenstackPathHelper
end

class OpenstackPathHelperTest < CleanTest
  def setup
    @model = TestModel.new
  end

  def test_openstack_path_production
    Rails.stub(:env, 'production') do
      assert_equal 'https://compute.datacentred.io', @model.openstack_path
    end
  end

  def test_openstack_path_other_envs
    ['development', 'test', 'staging', 'acceptance', 'dsffds'].each do |env|
      Rails.stub(:env, env) do
        assert_equal 'http://devstack.datacentred.io', @model.openstack_path
      end
    end
  end

end