require 'sirportly'

class TicketAdapter
  extend TicketsHelper
  extend ActionView::Helpers::TextHelper

  class << self
    def all(page=1)
      SIRPORTLY.request("tickets/contact", contact: Authorization.current_user.unique_id, page: page)["records"].sort_by{|t| t['updated_at']}.map do |t|
        head, *tail = SIRPORTLY.request("ticket_updates/all", ticket: t['reference']).sort_by{|t| t['posted_at']}
        updates = tail.map do |u|
          unless u['private']
            TicketComment.new(ticket_reference: t['reference'], id: u['id'],
                              email: u['from_address'], text: markdown(u['message']),
                              time: Time.parse(u['posted_at']),
                              staff: (u['author']["type"] == "User"),
                              name: u['from_name'])
          end
        end.compact
        description = (head ? head['message'] : nil)
        Ticket.new(comments: updates, description: markdown(description),
                   reference: t['reference'], title: t['subject'],
                   created_at: Time.parse(t['submitted_at']),
                   updated_at: Time.parse(t['updated_at']),
                   email: t['customer_contact_method']['data'],
                   name: t['customer']['name'],
                   status: t['status'],
                   department: t['department']['name'])
      end
    rescue Sirportly::Errors::NotFound
      return []
    end

    def departments
      Rails.cache.fetch("stronghold_departments", expires_in: 1.day) do
        SIRPORTLY.brands.select do |b|
          b.name.downcase == 'datacentred'
        end.first.departments.reject(&:private).collect(&:name).sort
      end
    end

    def priorities
      Rails.cache.fetch("stronghold_priorities", expires_in: 1.day) do
        SIRPORTLY.priorities.collect(&:name)
      end
    end

    def create(ticket)
      properties = {
        :brand => 'DataCentred',
        :department => ticket.department,
        :status => 'New',
        :priority => ticket.priority,
        :subject => ticket.title,
        :name => ticket.name,
        :email => ticket.email
      }
      new_ticket = SIRPORTLY.create_ticket(properties)
      update = new_ticket.post_update(:message => ticket.description, :customer => Authorization.current_user.unique_id)
      new_ticket.reference
    end

    def create_comment(comment)
      ticket  = SIRPORTLY.ticket(comment.ticket_reference)
      comment = ticket.post_update(:message => comment.text, :customer => Authorization.current_user.unique_id)
      ""
    end

    def change_status(reference, status)
      ticket = SIRPORTLY.ticket(reference)
      ticket.update(:status => status.downcase == 'open' ? 'New' : 'Resolved')      
      Hipchat.notify('Sirportly', 'Support', "<strong>#{Authorization.current_user.name}</strong> has updated ticket status (<a href=\"https://helpdesk.datacentred.io/staff/tickets/#{reference}\">#{reference}</a>) to #{status}.")
    end

  end
end