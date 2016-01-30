class Admin::OnlineUsersController < AdminBaseController
  def index
    @users = User.all.select(&:online_today?).sort{|x,y| y[:timestamp] <=> x[:timestamp]}
  end
end
