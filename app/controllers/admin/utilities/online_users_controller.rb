module Admin
  module Utilities
    class OnlineUsersController < UtilitiesBaseController
      def index
        @users = User.online
      end
    end
  end
end
