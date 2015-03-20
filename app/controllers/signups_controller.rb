class SignupsController < ApplicationController

  layout 'customer-sign-up'

  before_filter :find_invite, except: [:new, :create, :take_payment]
  before_filter :get_products, only: [:new, :create]

  def new
    @customer_signup = CustomerSignup.new
  end

  def create
    @customer_signup = CustomerSignup.new(create_params.merge(ip_address: request.remote_ip))
    if @customer_signup.save
      render :payment
    else
      flash[:error] = @customer_signup.errors.full_messages.join('<br>').html_safe
      render :new
    end
  end

  def take_payment
    @customer_signup = CustomerSignup.find_by_uuid(payment_params[:signup_uuid])
    customer = Stripe::Customer.create(
      :source => payment_params[:stripe_token],
      :email => @customer_signup.email,
      :description => "Company: #{@customer_signup.organization_name || '(no name)'}, Signup UUID: #{@customer_signup.uuid}"
    )
    @customer_signup.update_attributes(stripe_customer_id: customer.id)
    CustomerSignupJob.perform_later(@customer_signup.id)
    render :confirm
  end

  def edit
    layout 'sign-in'
    reset_session
    @registration = RegistrationGenerator.new(nil,{})  
  end

  def update
    layout 'sign-in'
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
    params.permit(:organization_name, :email, :first_name, :last_name,
                  :password, :confirm_password)
  end

  def payment_params
    params.permit(:stripe_token, :signup_uuid)
  end

  def get_products
    @products ||= Product.all
  end
end