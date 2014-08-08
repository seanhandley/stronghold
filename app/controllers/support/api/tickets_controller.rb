class Support::Api::TicketsController < SupportBaseController

  skip_authorization_check

  def index
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets
      }
      format.html
    end
  end

  def x
    respond_to do |format|
      format.json {
        render :json => "xyzxyz"
      }
      format.html
    end
  end

end