class SignupsController < ApplicationController

  layout 'login'

  def edit
    @invite = Invite.find_by_token(params[:token])
    if @invite && @invite.is_valid?
      render
    else
      raise ActionController::RoutingError.new('Not Found')
    end   
  end

  def update
    
  end
end