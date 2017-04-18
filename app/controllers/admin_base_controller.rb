class AdminBaseController < AuthorizedController
  skip_authorization_check
  before_action :check_user_is_staff

  layout 'admin'

  def current_section
    'admin'
  end

  private

  def check_user_is_staff
    return true if Rails.env.development?
    slow_404 unless current_user.staff? && current_user.admin?
  end
end