class Admin::OnlineUsersController < AdminBaseController
  def index
    @users = User.all.select(&:online_today?).sort do |x,y|
      y.last_known_connection[:timestamp] <=> x.last_known_connection[:timestamp]
    end
  end
end
