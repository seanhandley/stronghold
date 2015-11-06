class AdminBaseController < AuthorizedController
  skip_authorization_check
  before_filter :check_user_is_staff

  layout 'admin'

  private

  def check_user_is_staff
    return true if Rails.env.development?
    slow_404 unless current_user.staff?
  end
end