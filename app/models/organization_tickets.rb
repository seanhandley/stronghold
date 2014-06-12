class OrganizationTickets

  module IssueStatus
    ToDo       = 'To Do'
    InProgress = 'In Progress'
    Done       = 'Done'
  end

  def initialize(reference)
    @reference = reference
  end

  def all
    Rails.cache.fetch("organization_#{@reference}_tickets", expires_in: 20.seconds) do
      @tickets = SupportTicket.all @reference
    end
  end

  def open
    all.select do |issue|
      [
        ([IssueStatus::ToDo, IssueStatus::InProgress].include?(issue.fields['status']['name'])),
      ].all?
    end
  end

  def closed
    all.select do |issue|
      [
        (issue.fields['status']['name'] == IssueStatus::Done),
      ].all?
    end
  end

  def create(params)
    SupportTicket.create params.merge(reference: @reference)
  end

end