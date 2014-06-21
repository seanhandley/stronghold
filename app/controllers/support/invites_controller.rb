class Support::InvitesController < SupportBaseController

  skip_authorization_check

  def create
    roles = create_params[:roles].collect do |r|
      current_user.organization.roles.find(r.to_i)
    end.compact
    
    @invite = Invite.new(organization: current_user.organization,
                         email: create_params[:email], roles: roles)
    if @invite.save
      MailWorker.perform_async(:signup, @invite.id)
      javascript_redirect_to support_roles_path
    else
      render text: 'herp'
    end
  end

  private

  def create_params
    params.permit(:email, :roles => [])
  end

end