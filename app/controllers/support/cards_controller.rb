class Support::CardsController < SupportBaseController
  include ActionView::Helpers::UrlHelper

  skip_authorization_check

  def current_section
    'activate'
  end

  def new
    if current_user.organization.known_to_payment_gateway?
      redirect_to support_root_path
    else
      @location = GeoIp.geolocation(request.remote_ip)[:country_code] rescue 'GB'
      @customer_signup = current_user.organization.customer_signup
    end
  end

  def create
    @customer_signup = CustomerSignup.find_by_uuid(create_params[:signup_uuid])
    if @customer_signup.ready?
      args = {
          billing_address1: create_params[:address_line1],
          billing_address2: create_params[:address_line2],
          billing_city: create_params[:address_city],
          billing_postcode: create_params[:postcode],
          billing_country: create_params[:address_country].first,
        }.merge(create_params[:organization_name].present? ? {name: create_params[:organization_name]} : {})
      current_user.organization.update_attributes(args)
      signup_args = {stripe_customer_id: @customer_signup.stripe_customer_id}
      if(voucher = Voucher.find_by_code(create_params[:discount_code]))
        current_user.organization.vouchers << voucher
        signup_args.merge!(voucher: voucher)
      end
      current_user.organization.complete_signup!(signup_args)
      FraudCheckJob.set(wait: 10.seconds).perform_later(@customer_signup)
      Notifications.notify(:new_signup, "#{current_user.organization.name} has activated their account! Discount code: #{create_params[:discount_code].present? ? create_params[:discount_code] : 'N/A'}")

      reauthenticate(Rails.cache.fetch("up_#{current_user.uuid}"))
      Rails.cache.delete("up_#{current_user.uuid}")
      Announcement.create(title: 'Welcome', body: "Your account has been activated! Please check out our #{link_to 'Getting Started Guide', 'https://docs.datacentred.io/x/WQAJ', target: '_blank'}.".html_safe,
        limit_field: 'id', limit_value: current_user.id)
      redirect_to activated_path
    else
      render :new
    end
  end

  private

  def create_params
    params.permit(:stripe_token, :signup_uuid, :organization_name, :address_line1, :address_line2, :address_city,
                  :postcode, :discount_code, :address_country => [])
  end

end