class Support::CardsController < SupportBaseController

  skip_authorization_check

  def new
    if current_user.organization.known_to_payment_gateway?
      redirect_to support_root_path
    else
      @customer_signup = CustomerSignup.find_by_email(current_user.email)
    end
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
          billing_country: create_params[:address_country].first,
        }
      )
      if(voucher = Voucher.find_by_code(create_params[:discount_code]))
        current_user.organization.vouchers << voucher
      end
      current_user.organization.complete_signup! @customer_signup.stripe_customer_id
      Hipchat.notify('Self Service', 'Accounts',
                     "Good news! #{current_user.organization.name} is a paying customer! Voucher: #{create_params[:discount_code].present? ? create_params[:discount_code] : 'N/A'}",
                     color: 'green')
      reauthenticate(Rails.cache.fetch("up_#{current_user.uuid}"))
      Rails.cache.delete("up_#{current_user.uuid}")
      Announcement.create(title: 'Welcome', body: 'Your card details are verified and you may now begin using cloud services!',
        limit_field: 'id', limit_value: current_user.id)
      redirect_to support_root_path
    else
      render :new
    end
  end

  private

  def create_params
    params.permit(:stripe_token, :signup_uuid, :address_line1, :address_line2, :address_city,
                  :postcode, :discount_code, :address_country => [])
  end

end