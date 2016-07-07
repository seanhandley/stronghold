require 'test_helper'

class TestModel
  include CsvHelper
end

class CsvHelperTest < CleanTest
  def setup
    @model = TestModel.new
    @data = [{:name => 'test', :vcpu_hours => 1, :ram_tb_hours => 1, :openstack_tb_hours => 1,
              :ceph_tb_hours => 1, :load_balancer_hours => 1, :vpn_connection_hours => 1, :contacts => ['foo@bar.com'], :paying => true, :spend => 100.0,
              :resizes => [], :windows => false}]
    @expected = "Customer,VCPU hours,RAM TBh,OpenStack Storage TBh,Ceph Storage TBh,Load Balancer Hours,VPN Connection Hours,Admin Contact,Paying?,Spend (£),Resizes,Windows?\ntest,1.0,1.0,1.0,1.0,1.0,1.0,foo@bar.com,true,100.0,\"\",false\n"
  end

  def test_build_usage_report_csv
    assert_equal @expected, @model.build_usage_report_csv(@data)
  end

end