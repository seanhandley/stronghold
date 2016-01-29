class Admin::OnlineUsersController < AdminBaseController
  def index
    @users = User.all.select(&:online?) - [current_user]
  end
end
