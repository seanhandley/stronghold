class OrganizationTickets

  def initialize(reference)
    @reference = reference
  end

  def all
    Rails.cache.fetch("organization_#{@reference}_tickets", expires_in: 20.seconds) do
      @tickets = SupportTicket.all @reference
    end
  end

  def some_ticket(key)
    all.select do |issue|
      [
        (issue.key == key)
      ].first
    end
  end

  def create(params)
    SupportTicket.create params.merge(reference: @reference)
  end

end