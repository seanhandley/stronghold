class Admin::CustomersController < AdminBaseController

  def new
    @customer = CustomerGenerator.new
  end

  def create
    @customer = CustomerGenerator.new(create_params)
    if @customer.generate!
      redirect_to admin_root_path, notice: 'Customer created successfully'
    else
      flash[:error] = @customer.errors.full_messages.join('<br>')
      render :new
    end
  end

  private

  def create_params
    params.permit(:organization_name, :email,
                  :colo_only, :extra_tenants)
  end
end