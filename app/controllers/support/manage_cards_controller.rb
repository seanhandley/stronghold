class Support::ManageCardsController < AuthorizedController

  skip_authorization_check

  before_filter :get_stripe_customer

  def index
    @cards = @stripe_customer.sources
  end

  def update
    @stripe_customer.default_source = params[:id]
    @stripe_customer.save
    redirect_to support_manage_cards_path
  end

  def create
    @stripe_customer.sources.create(:source => create_params[:stripe_token])
    redirect_to support_manage_cards_path
  end

  def destroy
    if @stripe_customer.default_source != params[:id]
      @stripe_customer.sources.retrieve(params[:id]).delete
      redirect_to support_manage_cards_path
    else
      redirect_to support_manage_cards_path, notice: "You can't delete your default card."
    end
  end

  private

  def get_stripe_customer
    @stripe_customer ||= Stripe::Customer.retrieve(current_user.organization.stripe_customer_id)
  end

  def create_params
    params.permit(:stripe_token)
  end

end