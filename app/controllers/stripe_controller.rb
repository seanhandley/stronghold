class StripeController < ApplicationController
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

  private

  def payment_params
    params.permit(:stripe_token, :signup_uuid, :stripe_customer_id)
  end
end