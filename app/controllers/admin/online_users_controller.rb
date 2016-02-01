class Admin::OnlineUsersController < AdminBaseController
  def index
    @users = User.online
  end
end
