module Support
  module Api
    class TicketCommentsController < SupportBaseController

      include ApplicationHelper

      load_and_authorize_resource :class => "TicketComment"

      def create
        ticket_comment = TicketComment.new(
          :ticket_reference => create_params[:ticket_id],
          :text => create_params[:text],
          :email => Authorization.current_user.email
        )
        response = {
          :success => ticket_comment.valid?,
          :message => nil
        }
        if ticket_comment.valid?
          response["message"] = TicketAdapter.create_comment(ticket_comment)
        else
          response["message"] = get_model_errors(ticket_comment)
        end
        respond_to do |format|
          format.json {
            render :json => response
          }
        end
      end

      # def destroy
      #   issue_reference = params[:ticket_id]
      #   comment_id = params[:id]
      #   response = current_organization.tickets.destroy_comment(issue_reference, comment_id)
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
  end
end
