class OrganizationTickets

  def initialize(reference)
    @reference = reference
  end

  def open
    SupportTicket.open @reference
  end

  def closed
    SupportTicket.closed @reference
  end

  def create(params)
    SupportTicket.create params.merge(reference: @reference)
  end

end