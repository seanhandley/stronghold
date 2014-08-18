class SignupsController < ApplicationController

  layout 'sign-in'

  before_filter :find_invite

  def edit  
    @registration = Registration.new(nil,{})  
  end

  def update
    @registration = Registration.new(@invite, update_params)
    if @registration.process!
      session[:user_id] = @registration.user.id
      redirect_to support_root_path, notice: 'Welcome!'
    else
      flash[:error] = @registration.errors.full_messages.join('<br>')
      render :edit    
    end
  end

  private

  def update_params
    if !@invite.organization
      params.permit(:organization_name, :password, :confirm_password)
    else
      params.permit(:password, :confirm_password)
    end
  end

  def find_invite
    @invite = Invite.find_by_token(params[:token])
    raise ActionController::RoutingError.new('Not Found') unless @invite && @invite.can_register?
  end
end