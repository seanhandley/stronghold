class Support::AuditsController < SupportBaseController

  skip_authorization_check

  def index
    @audits = Audit.for_organization(current_user.organization).order('created_at DESC')
    @audits = @audits.page params[:page]
  end
end