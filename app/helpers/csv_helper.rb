module CsvHelper
  def build_usage_report_csv(data)
    CSV.generate do |csv|
      csv << ["Customer", "VCPU hours", "RAM TBh", "OpenStack Storage TBh", "Ceph Storage TBh", "Admin Contact", "Paying?", "Spend (£)"]
      data.each do |entry|
        csv << [entry[:name], entry[:vcpu_hours].round(1), entry[:ram_tb_hours].round(1), entry[:openstack_tb_hours].round(1),
                entry[:ceph_tb_hours].round(1), entry[:contacts].join(','), entry[:paying], entry[:spend].round(2)]
      end
    end
  end
end