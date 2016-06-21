class Admin::AuditsController < AdminBaseController
  def show
    @organization = Organization.find(params[:id])
    @audits = Audit.for_organization(@organization).order('created_at DESC').page params[:page]
  end
end
