class Support::Api::TicketCommentsController < SupportBaseController

  load_and_authorize_resource :class => "Ticket"

  def create
    issue_reference = params[:ticket_id]
    response = current_user.organization.tickets.create_comment(create_params)
    respond_to do |format|
      format.json {
        render :json => response
      }
    end
  end

  # def destroy
  #   issue_reference = params[:ticket_id]
  #   comment_id = params[:id]
  #   response = current_user.organization.tickets.destroy_comment(issue_reference, comment_id)
  #   respond_to do |format|
  #     format.json {
  #       render :json => response
  #     }
  #   end
  # end

  private

  def create_params
    params.permit(:ticket_id, :text)
  end

end