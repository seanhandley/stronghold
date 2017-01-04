module Admin
  module Utilities
    class SanityController < UtilitiesBaseController

      def index
        @syncs = Billing::Sync.where("completed_at > ?", Time.zone.now - 24.hours).order('completed_at DESC')
        @total = @syncs.collect{|s| s.instance_states.count + s.volume_states.count + s.ips.count + s.image_states.count }.sum
        @keys = ['instances', 'volumes', 'images', 'routers']
        #@data = Sanity.check
      end

    end
  end
end
