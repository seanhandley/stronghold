class MembershipsController < ApplicationController
  include ModelErrorsHelper

  layout "customer-sign-up"

  before_action :find_invite, except: [:thanks, :create]
  skip_before_action :verify_authenticity_token, :only => [:create], raise: false


  def confirm
    reset_session
    @membership = MembershipGenerator.new(nil)
  end

  def thanks
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @invite = Invite.find_by_token(params[:token])
    @membership = MembershipGenerator.new(@invite)
    if @membership.generate!
      session[:user_id] = @membership.user.id
      session[:created_at] = Time.zone.now
      session[:organization_id] = @invite.organization.id
      session[:token] = @membership.user.authenticate(@membership.user.password)
      redirect_to membership_thanks_path(@invite.organization)
    else
      flash.clear
      flash.now.alert = model_errors_as_html(@membership)
      render :confirm, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.permit(:user, :organization)
  end

  def find_invite
    @invite = Invite.find_by_token(params[:token])
    slow_404 unless @invite && @invite.can_register?
  end

end
