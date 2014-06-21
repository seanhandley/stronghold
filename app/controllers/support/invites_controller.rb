class Support::InvitesController < SupportBaseController

  load_and_authorize_resource param_method: :create_params

  def create
    roles = create_params[:roles].collect do |r|
      current_user.organization.roles.find(r.to_i)
    end.compact

    @invite = current_user.organization.create(create_params)
    if @invite.save
      MailWorker.perform_async(:signup, @invite.id)
      javascript_redirect_to support_roles_path
    else
      render text: 'herp'
    end
  end

  private

  def create_params
    params.require(:invite).permit(:email, :roles => [])
  end

end