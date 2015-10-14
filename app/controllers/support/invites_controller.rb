class Support::InvitesController < SupportBaseController

  load_and_authorize_resource param_method: :create_params

  def create
    roles = [create_params[:role_ids]].flatten.compact.collect do |r|
      current_organization.roles.find_by_id(r.to_i)
    end.compact

    @invite = current_organization.invites.create(create_params)
    if @invite.save
      javascript_redirect_to support_roles_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @invite} }
      end
    end
  end

  def destroy
    @invite = Invite.find(params[:id])
    if @invite.organization.id == current_organization.id
      if @invite.destroy
        javascript_redirect_to support_roles_path
      end
    end
  end

  private

  def create_params
    params.require(:invite).permit(:email, :role_ids => [])
  end

end
