require 'test_helper'

class TestModel
  include CsvHelper
end

class CsvHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
    @data = [{:name => 'test', :vcpu_hours => 1, :ram_tb_hours => 1, :openstack_tb_hours => 1,
              :ceph_tb_hours => 1, :contacts => ['foo@bar.com'], :paying => true, :spend => 100.0}]
    @expected = "Customer,VCPU hours,RAM TBh,OpenStack Storage TBh,Ceph Storage TBh,Admin Contact,Paying?,Spend (£)\ntest,1.0,1.0,1.0,1.0,foo@bar.com,true,100.0\n"
  end

  def test_build_usage_report_csv
    assert_equal @expected, @model.build_usage_report_csv(@data)
  end

end