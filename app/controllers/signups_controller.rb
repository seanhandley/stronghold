class SignupsController < ApplicationController

  layout 'sign-in'
  layout 'customer-sign-up', only: [:new, :create]

  before_filter :find_invite, except: [:new, :create, :take_payment]
  before_filter :get_products, only: [:new, :create]

  def new
    @customer_signup = CustomerSignup.new
  end

  def create
    @customer_signup = CustomerSignup.new(create_params)
    # @csg = CustomerSignupGenerator.new(@customer_signup)
    if @customer_signup.save
      render :payment
    else
      flash[:error] = @customer_signup.errors.full_messages.join('<br>').html_safe
      render :new
    end
  end

  def take_payment
    render text: params.inspect
    # Turn the stripe token into a customer and save the customer ID with the signup object
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
    params.permit(:organization_name, :email, :first_name, :last_name,
                  :password, :confirm_password)
  end

  def get_products
    @products ||= Product.all
  end
end