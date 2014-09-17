require 'sirportly'

class TicketAdapter
  extend TicketsHelper
  extend ActionView::Helpers::TextHelper

  class << self
    def all(page = 1)
      SIRPORTLY.request("tickets/contact", contact: Authorization.current_user.id, page: page)["records"].map do |t|
        head, *tail = SIRPORTLY.request("ticket_updates/all", ticket: t['reference'])
        updates = tail.map do |u|
          unless u['private']
            TicketComment.new(ticket_reference: t['reference'], id: u['id'],
                              email: u['from_address'], text: markdown(u['message']),
                              time: Time.parse(u['posted_at']))
          end
        end.compact
        description = (head ? head['message'] : nil)
        Ticket.new(comments: updates, description: markdown(description),
                   reference: t['reference'], title: t['subject'],
                   created_at: Time.parse(t['submitted_at']),
                   updated_at: Time.parse(t['updated_at']),
                   user: User.find_by_id(t['customer']['reference']),
                   email: t['customer_contact_method']['data'],
                   status: t['status'])
      end
    end

    def create(ticket)
      # title = truncate_for_audit(ticket.title)
      # description = truncate_for_audit(ticket.description)
      # audit(reference, 'create', {title: title, description: description})

      properties = {
        :brand => 'DataCentred',
        :department => 'Support',
        :status => 'New',
        :priority => 'Normal',
        :subject => ticket.title,
        :name => ticket.user.name,
        :email => ticket.user.email
      }
      new_ticket = SIRPORTLY.create_ticket(properties)
      update = new_ticket.post_update(:message => ticket.description, :customer => Authorization.current_user.id)
      # Hipchat.notify('Support', "New ticket <a href=\"https://datacentred.atlassian.net/browse/#{reference}\">#{reference}</a> created by #{ticket.email}: #{title}")
      new_ticket.reference
    end

    def create_comment(comment)
      ticket  = SIRPORTLY.ticket(comment.ticket_reference)
      comment = ticket.post_update(:message => comment.text, :customer => Authorization.current_user.id)

      #Hipchat.notify('Support', "#{ticket_comment.email} replied to ticket <a href=\"https://datacentred.atlassian.net/browse/#{ticket_comment.ticket_reference}\">#{ticket_comment.ticket_reference}</a>: #{text}")
      ""
    end

    def change_status(reference, status)
      ticket = SIRPORTLY.ticket(reference)
      ticket.update(:status => status.downcase == 'open' ? 'New' : 'Resolved')
      # audit(reference, 'update_status', {reference: reference, status: status})
    end

    private

    def audit(id, action, params)
      Audited::Adapters::ActiveRecord::Audit.create auditable_id: id, auditable_type: 'Ticket', action: action,
                   user: Authorization.current_user,
                   organization_id: Authorization.current_user.organization_id,
                   audited_changes: params.stringify_keys!
    end

    def truncate_for_audit(content)
      truncate(content, omission: '...', separator: '', length: 300)
    end
  end
end