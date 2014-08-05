class Organization < ActiveRecord::Base
  after_save :generate_reference, :on => :create

  validates :name, length: {minimum: 1}, allow_blank: false
  validates :reference, :uniqueness => true

  has_many :users
  has_many :roles
  has_many :invites

  def tickets
    jiraIssues = Rails.cache.fetch("organization_#{@reference}_tickets", expires_in: 1.seconds) do
      JiraIssue.all reference
    end
    tickets = []
    jiraIssues.each do |jiraIssue|
      ticket = OrganizationTicket.new(reference: jiraIssue.attrs['key'])
      ticket.title = jiraIssue.attrs['fields']['summary']
      ticket.description = jiraIssue.attrs['fields']['description']
      ticket.jira_status = jiraIssue.attrs['fields']['status']['name']
      tickets.push(ticket)
    end
    tickets
  end

  def ticket(key)
    tickets.select do |ticket|
      [
        (ticket.key == key)
      ].first
    end
  end

  def create_ticket(params)
    JiraIssue.create params.merge(reference: @reference)
  end

  private

  def generate_reference
    return nil if reference
    generate_reference_step(name.parameterize.gsub('-','').upcase.slice(0,8), 0)
  end

  def generate_reference_step(ref, count)
    new_ref = "#{ref}#{count == 0 ? '' : count }"
    if Organization.all.collect(&:reference).include?(new_ref)
      generate_reference_step(ref, (count+1))
    else
      update_column(:reference, new_ref)
    end
  end

end