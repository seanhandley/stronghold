class Admin::PendingCustomersController < AdminBaseController

  def index
    @pending_customers = Organization.pending
  end

  def update
    organization = Organization.find(params[:id])
    if organization.manually_activate!
      Announcement.create(title: 'Welcome', body: 'Your identity is verified and you may now begin using cloud services!',
        limit_field: 'id', limit_value: organization.users.first.id)
      redirect_to admin_pending_customers_path, notice: 'Success!'
    else
      redirect_to admin_pending_customers_path, alert: 'Failed to activate...'
    end
  end

end
