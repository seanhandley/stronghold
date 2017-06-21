class AdminBaseController < AuthorizedController
  skip_authorization_check
  before_action :check_user_is_staff

  layout 'admin'

  def current_section
    'admin'
  end

  private

  def check_user_is_staff
    redirect_to support_root_path unless current_organization.staff? && current_user.admin?
  end
end
