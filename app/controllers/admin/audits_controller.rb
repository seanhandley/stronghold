module Admin
  class AuditsController < AdminBaseController
    def show
      @organization = Organization.find(params[:id])
      @audits = Audit.for_organization_and_user(@organization, current_user).order('created_at DESC').page params[:page]
    end
  end
end
