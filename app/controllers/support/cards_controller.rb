class Support::CardsController < LocallyAuthorizedController
  
  def index

  end

  def new
    @customer_signup = CustomerSignup.find_by_email(current_user.email)
  end

  def create
    @customer_signup = CustomerSignup.find_by_uuid(create_params[:signup_uuid])
    if @customer_signup.ready?
      current_user.organization.update_attributes(
        {
          billing_address1: create_params[:address_line1],
          billing_address2: create_params[:address_line2],
          billing_city: create_params[:address_city],
          billing_postcode: create_params[:postcode],
          billing_country: Country.find_country_by_alpha2(create_params[:address_country].first),
        }
      )
      current_user.organization.complete_signup! @customer_signup.stripe_customer_id
      session[:token] = current_user.authenticate(Rails.cache.fetch("up_#{current_user.uuid}"))
      Rails.cache.delete("up_#{current_user.uuid}")
      Announcement.create(title: 'Welcome', body: 'Your card details are verified and you may now begin using cloud services!',
        limit_field: 'id', limit_value: current_user.id)
      redirect_to support_root_path
    else
      render :new
    end
  end

  def edit

  end

  def update

  end

  private

  def create_params
    params.permit(:stripe_token, :signup_uuid, :address_line1, :address_line2, :address_city,
                  :postcode, :address_country => [])
  end

end