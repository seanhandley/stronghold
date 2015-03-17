class SignupsController < ApplicationController

  layout 'sign-in'
  layout 'customer-sign-up', only: [:new]

  before_filter :find_invite, except: [:new, :create]
  before_filter :get_products, only: [:new, :create]

  def new
    @customer_signup = CustomerSignupGenerator.new
  end

  def create
    @customer_signup = CustomerSignupGenerator.new(create_params)
    @organization = Organization.new(create_params[:organization])
    if @customer_signup.generate!
      redirect_to support_root_path
    else
      flash[:error] = @customer_signup.errors.full_messages.join('<br>')
      render :new
    end
  end

  def edit
    reset_session
    @registration = RegistrationGenerator.new(nil,{})  
  end

  def update
    @registration = RegistrationGenerator.new(@invite, update_params)
    if @registration.generate!
      session[:user_id] = @registration.user.id
      session[:created_at] = Time.zone.now
      redirect_to support_root_path, notice: 'Welcome!'
    else
      flash[:error] = @registration.errors.full_messages.join('<br>')
      render :edit    
    end
  end

  private

  def update_params
    params.permit(:password, :confirm_password, :privacy,
                  :first_name, :last_name)
  end

  def find_invite
    @invite = Invite.find_by_token(params[:token])
    raise ActionController::RoutingError.new('Not Found') unless @invite && @invite.can_register?
  end

  def create_params
    params.permit(:organization_name, :email,
                  :organization => {:product_ids => []})
  end

  def get_products
    @products ||= Product.all
  end
end