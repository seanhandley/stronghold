module Support
  module Api
    class AttachmentsController < SupportBaseController
      skip_before_action :verify_authenticity_token, only: [:create]
      
      load_and_authorize_resource :class => "Ticket"

      include ApplicationHelper
      include TicketOwnership
      include SafeFileUploads

      def create
        attachment = create_params[:file]
        attachment = UploadIO.new attachment,
                     attachment.content_type,
                     attachment.original_filename
        ticket_id  = create_params[:ticket_id]
        @ticket = SIRPORTLY.ticket(ticket_id)
        @ticket.add_attachment :ticket => @ticket.reference,
                               :update => @ticket.updates[0].id,
                               :file   => attachment
      end

      private

      def create_params
        params.permit(:ticket_id, :file, :safe_upload_token)
      end

    end
  end
end
