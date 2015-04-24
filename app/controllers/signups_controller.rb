class SignupsController < ApplicationController

  layout :set_layout

  before_filter :find_invite, except: [:new, :create]

  def new
    if current_user
      redirect_to support_root_path
    else
      @customer_signup = CustomerSignup.new
    end
  end

  def create
    @customer_signup = CustomerSignup.new(create_params.merge(ip_address: request.remote_ip))
    if @customer_signup.save
      CustomerSignupJob.perform_later(@customer_signup.id)
      render :confirm
    else
      flash[:error] = @customer_signup.errors.full_messages.join('<br>').html_safe
      render :new
    end
  end

  def edit
    reset_session
    @registration = RegistrationGenerator.new(nil,{})  
  end

  def update
    @registration = RegistrationGenerator.new(@invite, update_params)
    if verify_recaptcha(:model => @registration) && @registration.generate!
      Rails.cache.write("up_#{@registration.user.uuid}", update_params[:password], expires_in: 60.minutes)
      session[:user_id] = @registration.user.id
      session[:created_at] = Time.zone.now
      session[:token] = @registration.user.authenticate(update_params[:password])
      redirect_to support_root_path
    else
      flash[:error] = @registration.errors.full_messages.join('<br>')
      render :edit    
    end
  end

  private

  def current_ability
    @current_ability ||= User::Ability.new(current_user)
  end

  def set_layout
    case action_name
    when "edit", "update"
      "sign-in"
    when "new", "create"
      "customer-sign-up"
    else
      "application"
    end
  end

  def update_params
    params.permit(:password, :confirm_password,
                  :first_name, :last_name)
  end

  def find_invite
    @invite = Invite.find_by_token(params[:token])
    raise ActionController::RoutingError.new('Not Found') unless @invite && @invite.can_register?
  end

  def create_params
    params.permit(:organization_name, :email, :first_name, :last_name,
                  :password, :confirm_password)
  end

end