require 'csv'

module CsvHelper
  def build_usage_report_csv(data)
    CSV.generate do |csv|
      csv << ["Customer", "VCPU hours", "RAM TBh", "OpenStack Storage TBh", "Ceph Storage TBh", "Load Balancer Hours", "VPN Connection Hours", "Admin Contact", "Paying?", "Spend (£)"]
      data.each do |entry|
        csv << [entry[:name], entry[:vcpu_hours].round(1), entry[:ram_tb_hours].round(1), entry[:openstack_tb_hours].round(1),
                entry[:ceph_tb_hours].round(1), entry[:load_balancer_hours].round(2), entry[:vpn_connection_hours],
                entry[:contacts].join(','), entry[:paying], entry[:spend].round(2)]
      end
    end
  end
end