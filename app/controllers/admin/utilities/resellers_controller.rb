module Admin
  module Utilities
    # This ResellersController class is responsible for supplying plattform stats fot hte view. 
    class ResellersController < UtilitiesBaseController
      include ActionView::Helpers::NumberHelper

      def index
        @platform_stats = get_platform_stats
      end

      private

      def get_platform_stats
        {"count"=>1, "vcpus_used"=>0, "local_gb_used"=>0, "memory_mb"=>16048, "current_workload"=>0, "vcpus"=>8, "running_vms"=>0, "free_disk_gb"=>78, "disk_available_least"=>55, "local_gb"=>78, "free_ram_mb"=>15536, "memory_mb_used"=>512}
        Rails.cache.fetch('platform_stats', expires_in: 5.minutes) do
          stats = OpenStackConnection.compute.get_hypervisor_statistics(nil).body["hypervisor_statistics"]
          {
            vcpu: {
              used:  number_with_delimiter(stats['vcpus_used']),
              total: number_with_delimiter(stats['vcpus']),
              percentage: ((stats['vcpus_used'].to_f / stats['vcpus'].to_f) * 100).round(2)
            },
            ram: {
              used:  number_with_delimiter((stats['memory_mb_used'].to_f / 1048576.0).round(2)),
              total: number_with_delimiter((stats['memory_mb'].to_f / 1048576.0).round(2)),
              percentage: ((stats['memory_mb_used'].to_f / stats['memory_mb'].to_f) * 100).round(2)
            },
            disk: {
              used:  number_with_delimiter((stats['local_gb_used'].to_f / 1048576.0).round(3)),
              total: number_with_delimiter((stats['local_gb'].to_f / 1048576.0).round(3)),
              percentage: ((stats['local_gb_used'].to_f / stats['local_gb'].to_f) * 100).round(2)
            }
          }
        end
      end
    end
  end
end
