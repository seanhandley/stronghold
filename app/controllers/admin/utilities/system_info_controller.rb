module Admin
  module Utilities
    class SystemInfoController < UtilitiesBaseController
      def index
        @system_info = Rails::Info.to_html
      end
    end
  end
end
