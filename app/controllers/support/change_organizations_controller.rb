module Support
  class ChangeOrganizationsController < SupportBaseController
    skip_authorization_check

    def organization_id
      @organization_id  ||= params[:organization_id].to_i
    end

    def change
      if current_user.organization_ids.include?(organization_id)
        session[:organization_id] = params[:organization_id]
        cookies.signed[:current_organization_id] = params[:organization_id]
        redirect_to redirect_location, notice: 'Account changed successfully.'
      else
        redirect_to redirect_location, alert: "Action not allowed."
      end
    end

    private

    def redirect_location
      request.referrer || support_root_path
    end

  end
end
