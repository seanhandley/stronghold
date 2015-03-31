class Support::CardsController < SupportBaseController
  
  def index

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

  end

  def update

  end

  private

  def update_params
    params.permit(:password, :confirm_password, :privacy,
                  :first_name, :last_name)
  end

  def create_params
    params.permit(:organization_name, :email, :first_name, :last_name,
                  :password, :confirm_password)
  end

  def payment_params
    params.permit(:stripe_token, :signup_uuid)
  end

end