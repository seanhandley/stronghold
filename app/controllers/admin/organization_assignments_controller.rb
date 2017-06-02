class Admin::OrganizationAssignmentsController < AdminBaseController
  include ModelErrorsHelper
  before_action :fetch_organization

  def create
    @organization_user = OrganizationUser.create organization: @organization,
                                                 user:         current_user,
                                                 duration:     OrganizationUser::DEFAULT_MEMBERSHIP_DURATION_IN_HOURS
    if @organization_user.save
      redirect_to admin_customer_path(@organization), notice: "You have added yourself to this account."
    else
      redirect_to admin_customer_path(@organization), alert: model_errors_as_html(@organization_user)
    end
  end

  def destroy
    @organization_user = OrganizationUser.find_by organization: @organization, user: current_user
    if @organization_user.destroy
      redirect_to admin_customer_path(@organization), notice: "You have removed yourself from this account."
    else
      redirect_to admin_customer_path(@organization), alert: model_errors_as_html(@organization_user)
    end
  end

  def update
    @organization_user = OrganizationUser.find_by organization: @organization, user: current_user
    if @organization_user.reset!
      redirect_to admin_customer_path(@organization), notice: "You have restarted your membership timer."
    else
      redirect_to admin_customer_path(@organization), alert: model_errors_as_html(@organization_user)
    end
  end

  private

  def fetch_organization
    @organization ||= Organization.find params[:id]
  end
end
