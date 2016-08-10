module Support
  class ChangeOrganizationsController < SupportBaseController
    skip_authorization_check
    before_action :fetch_organization_id

    def fetch_organization_id
      @organization_id  ||= params[:organization_id].to_i
    end

    def change
      if current_user.organization_ids.include?(@organization_id)
        session[:organization_id] = params[:organization_id]
        redirect_to support_root_path, notice: 'Account changed successfully.'
      else
        redirect_to support_root_path, alert: "Action not allowed."
      end
    end

  end
end
