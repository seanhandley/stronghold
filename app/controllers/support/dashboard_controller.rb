class Support::DashboardController < SupportBaseController

  skip_authorization_check

  def current_section
    'dashboard'
  end

  def index
    
  end

end