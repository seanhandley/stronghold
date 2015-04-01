class SignupsController < ApplicationController

  layout :set_layout

  before_filter :find_invite, except: [:new, :create, :pay, :take_payment, :precheck]

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

  def pay
    @customer_signup = CustomerSignup.find_by_email(current_user.email)
  end

  def take_payment
    @customer_signup = CustomerSignup.find_by_uuid(payment_params[:signup_uuid])
    if @customer_signup.ready?
      CustomerEnableAccountJob.perform_later(current_user.organization.id,
                               @customer_signup.stripe_customer_id)
      render :paid
    else
      render :new
    end
  end

  # Ajax
  def precheck
    @customer_signup = CustomerSignup.find_by_uuid(payment_params[:signup_uuid])
    customer = Stripe::Customer.create(
      :source => payment_params[:stripe_token],
      :email => @customer_signup.email,
      :description => "Company: #{@customer_signup.organization_name}, Signup UUID: #{@customer_signup.uuid}"
    )
    @customer_signup.update_attributes(stripe_customer_id: customer.id)
    if @customer_signup.ready?    
      render json: {success: true, message: ''}
    else
      customer.delete
      render json: {success: false, message: 'The address does not match the card'}
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
    params.permit(:password, :confirm_password, :privacy,
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

  def payment_params
    params.permit(:stripe_token, :signup_uuid)
  end

end