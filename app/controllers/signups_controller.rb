class SignupsController < ApplicationController
  include ModelErrorsHelper

  layout "customer-sign-up"

  before_action :find_invite, except: [:new, :create, :thanks]
  skip_before_action :verify_authenticity_token, :only => [:create], raise: false

  def new
    if current_user
      redirect_to support_root_path
    else
      @email = params[:email]
      @customer_signup = CustomerSignup.new
    end
  end

  def create
    extra_headers = { ip_address: request.remote_ip,
                      real_ip: request.headers['X-Real-IP'],
                      forwarded_ip: request.headers['X-Forwarded-For'],
                      accept_language: request.headers['Accept-Language'],
                      user_agent: request.headers['User-Agent'],
                      device_id: device_cookie
                    }
    @customer_signup = CustomerSignup.new(create_params.merge(extra_headers))
    msg = "Unfortunately, we are currently unable to accept signups."
    respond_to do |format|
      format.html {
        flash.now.alert = msg
        render :new, status: :unprocessable_entity
      }
      format.json { render json: {errors: msg, status: :unprocessable_entity } }
    end

    # if @customer_signup.save
    #   respond_to do |format|
    #     format.html { redirect_to thanks_path }
    #     format.json { head :ok }
    #   end
    # else
    #   respond_to do |format|
    #     format.html {
    #       flash.now.alert = model_errors_as_html(@customer_signup)
    #       render :new, status: :unprocessable_entity
    #     }
    #     format.json { render json: {errors: model_errors_as_html(@customer_signup)}, status: :unprocessable_entity }
    #   end
    # end
  end

  def thanks
    if current_user
      redirect_to support_root_path
    else
      render :confirm
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
      session[:organization_id] = @invite.organization.id
      session[:token] = @registration.user.authenticate(update_params[:password])
      redirect_to current_organization.known_to_payment_gateway? ? support_root_path : activate_path
    else
      flash.clear
      flash.now.alert = model_errors_as_html(@registration)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.permit(:password)
  end

  def find_invite
    @invite = Invite.find_by_token(params[:token])
    slow_404 unless @invite && @invite.can_register?
  end

  def create_params
    params.permit(:email, :discount_code)
  end
  
end
