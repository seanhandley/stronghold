class Admin::OrganizationAssignmentsController < AdminBaseController
  include ModelErrorsHelper
  before_action :fetch_organization

  def create
    @organization_user = OrganizationUser.create organization_id: @organization_id, user_id: current_user.id
    if @organization_user.save
      redirect_to admin_customer_path(@organization_id), notice: "You have added yourself to this account."
    else
      redirect_to admin_customer_path(@organization_id), alert: model_errors_as_html(@organization_user)
    end
  end

  def destroy
    @organization_user = OrganizationUser.where(:organization_id => @organization_id, :user_id => current_user.id).first
    if @organization_user.destroy
      redirect_to admin_customer_path(@organization_id), notice: "You have removed yourself from this account."
    else
      redirect_to admin_customer_path(@organization_id), alert: model_errors_as_html(@organization_user)
    end
  end

  private

  def fetch_organization
    @organization_id = params[:organization][:id]
  end

  def create_params
    params.permit(:id)
  end
end
