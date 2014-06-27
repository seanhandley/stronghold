class Support::InvitesController < SupportBaseController

  load_and_authorize_resource param_method: :create_params

  def create
    roles = [create_params[:role_ids]].flatten.compact.collect do |r|
      current_user.organization.roles.find_by_id(r.to_i)
    end.compact

    @invite = current_user.organization.invites.create(create_params)
    if @invite.save
      MailWorker.perform_async(:signup, @invite.id)
      javascript_redirect_to support_roles_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @invite} }
      end
    end
  end

  private

  def create_params
    params.require(:invite).permit(:email, :role_ids => [])
  end

end
