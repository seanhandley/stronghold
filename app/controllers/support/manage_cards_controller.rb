class Support::ManageCardsController < AuthorizedController

  skip_authorization_check

  before_filter :check_self_service_and_power, :get_stripe_customer

  def index
    @cards = @stripe_customer.sources
  end

  def update
    @stripe_customer.default_source = params[:id]
    @stripe_customer.save
    redirect_to support_manage_cards_path, notice: "Card successfully set as default"
  end

  def create
    @stripe_customer.sources.create(:source => create_params[:stripe_token])
    redirect_to support_manage_cards_path, notice: "New card added successfully"
  rescue Stripe::CardError => e
    redirect_to support_manage_cards_path, alert: e.message
  rescue Stripe::APIConnectionError
    redirect_to support_manage_cards_path, alert: "Payment provider isn't responding. Please try again."
  rescue Stripe::Error => e
    notify_honeybadger(e)
    redirect_to support_manage_cards_path, alert: "We're sorry - something went wrong. Our tech team has been notified."}
  end

  rescue Stripe::CardError => e
    render json: {success: false, message: e.message}
  rescue Stripe::APIConnectionError
    render json: {success: false, message: "Payment provider isn't responding. Please try again."}
  rescue Stripe::Error => e
    notify_honeybadger(e)
    render json: {success: false, message: "We're sorry - something went wrong. Our tech team has been notified."}
  end


  def destroy
    if @stripe_customer.default_source != params[:id]
      @stripe_customer.sources.retrieve(params[:id]).delete
      redirect_to support_manage_cards_path
    else
      redirect_to support_manage_cards_path, alert: "You can't delete your default card."
    end
  end

  private

  def get_stripe_customer
    @stripe_customer ||= Stripe::Customer.retrieve(current_user.organization.stripe_customer_id)
  end

  def create_params
    params.permit(:stripe_token)
  end

  def check_self_service_and_power
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user? && current_user.organization.self_service?
  end

end