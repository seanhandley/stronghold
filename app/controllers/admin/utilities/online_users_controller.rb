class Admin::Utilities::OnlineUsersController < UtilitiesBaseController
  def index
    @users = User.online
  end
end
