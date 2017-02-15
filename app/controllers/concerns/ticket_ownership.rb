module TicketOwnership
  extend ActiveSupport::Concern

  included do
    before_action :check_ticket_ownership, only: [:create, :update, :destroy]
  end

  protected

  def check_ticket_ownership
    slow_404 unless ticket.custom_fields["company_reference"] == current_organization.reporting_code
  end

  def ticket_ownership_params
    params.permit(:ticket_id)
  end

  def ticket
    @ticket ||= SIRPORTLY.ticket(ticket_ownership_params[:ticket_id])
  end
end
