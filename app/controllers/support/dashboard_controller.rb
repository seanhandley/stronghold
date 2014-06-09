class Support::DashboardController < SupportBaseController

  skip_authorization_check

  def current_section
    'dashboard'
  end

  def css
    
  end

  def components
    
  end

  def index
    redirect_to support_roles_path
  end

end