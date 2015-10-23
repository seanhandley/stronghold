class StaffConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    return false if (Time.now.utc - Time.parse(request.session[:created_at].to_s).utc) > SESSION_TIMEOUT.minutes
    user = User.find request.session[:user_id]
    user && user.staff?
  end
end
