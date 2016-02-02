module Ceph
  class Usage < CephObject::Usage

    def self.kilobytes_for(project_id)
      response = get uid: project_id, stats: true
      response.collect do |r|
        (r['usage'] && r['usage']['rgw.main']) ? r['usage']['rgw.main']["size_kb_actual"] : 0
      end.sum
    end

    private

    def self.date_format(datetime)
      datetime.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
