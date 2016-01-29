class Admin::OnlineUsersController < AdminBaseController
  def index
    @users = User.all.select(&:online_today?).sort{|x,y| x[:timestamp] <=> y[:timestamp]}
  end
end
