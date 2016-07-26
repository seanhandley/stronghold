require 'thread/pool'

module Billing
  module Bandwidths

    def self.sync!(from, to, sync)
      Project.with_deleted.each do |project|
        gigabytes = gigabytes_for_project(project.uuid, from, to)
        next unless gigabytes > 0
        Billing::Bandwidth.create gigabytes: gigabytes,
                                  project_id: project.uuid,
                                  billing_sync: sync,
                                  from: from,
                                  to: to
      end
    end

    def self.usage(project_id, from, to)
      query = "billing_bandwidths.from >= ? AND billing_bandwidths.to <= ? AND billing_bandwidths.project_id = ?"
      gigabytes = Billing::Bandwidth.where(query, from, to, project_id).map(&:gigabytes).sum
      {
        gigabytes: gigabytes,
        bytes: gigabytes * (1024.0 ** 3),
        cost: cost(gigabytes)
      }
    end

    def self.gigabytes_for_project(project_id, from, to)
      bytes_for_project(project_id, from, to) / (1024.0 ** 3)
    end

    def self.bytes_for_project(project_id, from, to)
      byte_counts = []
      pool = Thread.pool(7)
      
      ips = Billing::Ip.where(project_id: project_id)
      ips = ips.map{|ip| Billing::Ip.where(address: ip.address)}.flatten.uniq
      # ips is now all IPs this project has owned, plus any other allocations
      ips.group_by(&:address).each do |address, allocations|
        pool.process do
          up_to = to
          # Newest first
          allocations = allocations.sort_by(&:recorded_at).reverse
          allocations.reject! {|allocation| allocation.recorded_at > to}
          allocations.each do |allocation|
            if allocation.recorded_at > from
              if allocation.project_id == project_id
                byte_counts << bytes(address, allocation.recorded_at, up_to)
              end
              up_to = allocation.recorded_at
            else
              if allocation.project_id == project_id
                byte_counts << bytes(address, from, up_to)
              end
              break
            end
          end
        end
      end

      pool.shutdown

      byte_counts.sum 
    end

    def self.bytes(ip_address, from, to)
      key = "bandwidth_bytes_#{ip_address}_#{from.strftime(timestamp_format)}_#{to.strftime(timestamp_format)}"
      Rails.cache.fetch(key, expires_in: 1.day) do
        result = ES_CLIENT.search body: query_hash(ip_address, from, to), size: 0
        result['aggregations']['total_bytes']['total_bytes']['value']
      end
    end

    def self.cost(gigabytes)
      # gigabytes = bytes / (1024.0 ** 3)
      # Data transfer (public internet) First 10TB  during Month GB  £0.0600
      first_ten_rate = 0.06
      # Data transfer (public internet) 10TB – 50TB during Month GB  £0.0500
      ten_to_fifty_rate = 0.05
      # Data transfer (public internet) Above 50TB  during Month GB  £0.0400
      fifty_plus_rate = 0.04

      rate_a = [gigabytes, 10 * 1024].min * first_ten_rate
      rate_b = [[gigabytes - 10 * 1024, 40 * 1024].min * ten_to_fifty_rate, 0].max
      rate_c = [(gigabytes - 50 * 1024) * fifty_plus_rate, 0].max

      {
        rate_a: rate_a.nearest_penny,
        rate_b: rate_b.nearest_penny,
        rate_c: rate_c.nearest_penny,
        total: [rate_a.nearest_penny, rate_b.nearest_penny, rate_c.nearest_penny].sum
      }
    end

    private

    def self.timestamp_format
      "%Y%m%d%H%M%S"
    end

    def self.range_filter(from, to)
      {
        "range": {
          "@timestamp": {
            "gte": from.to_i * 1000,
            "lt": to.to_i * 1000
          }
        }
      }
    end

    def self.query_hash(ip_address, from, to)
      {
        "query": {
          "multi_match": {
            "query": ip_address,
            "fields": ["ip_src","ip_dst"]
          }
        },
        "aggs": {
          "total_bytes": {
            "filter": range_filter(from, to),
            "aggs": {
              "total_bytes": { "sum": { "field": "bytes" } }
            }
          }
        }
      }
    end

  end
end
