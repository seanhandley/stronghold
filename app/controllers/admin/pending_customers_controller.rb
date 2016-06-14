class Admin::PendingCustomersController < AdminBaseController

  def update
    organization = Organization.find(params[:id])
    if organization.manually_activate!
      Starburst::Announcement.create!(body: "<strong><i class='fa fa-bullhorn'></i> Welcome:</strong> Your identity is verified and you may now begin using cloud services!".html_safe,
        limit_to_users: [{field: 'id', value: organization.users.first.id}]) if organization.users.any?

      Notifications.notify(:new_signup, "#{organization.name} is a paying customer! (Manually activated by #{current_user.name})")
      redirect_to admin_customer_path, notice: 'Success!'
    else
      redirect_to admin_customer_path, alert: 'Failed to activate...'
    end
  end

  def destroy
    organization = Organization.find(params[:id])
    if organization.destroy
      redirect_to admin_customer_path, notice: "Successfully deleted."
    else
      redirect_to admin_customer_path, alert: "Failed to destroy"
    end
  end

end
