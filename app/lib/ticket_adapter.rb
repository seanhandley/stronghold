require 'sirportly'

class TicketAdapter
  extend ActionView::Helpers::NumberHelper
  extend TicketsHelper
  extend ActionView::Helpers::TextHelper

  class << self
    def all(page=1, organization=Authorization.current_organization)
      tickets = []
      limit = 15
      page = page.to_i
      offset = page > 1 ? ((page - 1) * limit) : nil
      limit = [offset, limit].compact
      columns = %w{reference subject submitted_at updated_at
                   contact_methods.data priorities.name
                   contacts.name statuses.status_type departments.name
                   brands.name
                   custom_field.visitor_names
                   custom_field.date_of_visit
                   custom_field.time_of_visit
                   custom_field.more_info
                   custom_field.company_reference
                  }
      spql = "SELECT #{columns.join(',')} FROM tickets WHERE custom_field.company_reference = \"#{organization.reporting_code}\" AND brands.name = \"#{SIRPORTLY_BRAND}\" GROUP BY submitted_at ORDER BY submitted_at DESC LIMIT #{limit.join(',')}"
      user = Authorization.current_user
      colo_user = Authorization.current_organization.colo? && !Authorization.current_organization.cloud?
      unread_tickets = user.unread_tickets.map(&:ticket_id)
      SIRPORTLY.request("tickets/spql", spql: spql)["results"].map{|t| Hash[columns.zip(t)]}.map do |t|
        Thread.new do
          head, *tail = SIRPORTLY.request("ticket_updates/all", ticket: t['reference']).sort_by{|t| t['posted_at']}
          updates = tail.map do |u|
            unless u['private']
              ::TicketComment.new(ticket_reference: t['reference'], id: u['id'],
                                email: u['from_address'], text: markdown(u['message']),
                                time: Time.parse(u['posted_at']),
                                staff: (u['author'].try(:[], "type") == "User"),
                                name: u['from_name'].present? ? u['from_name'] : "Unregistered User")
            end
          end.compact
          description = (head ? head['message'] : nil)
          params = { comments: updates, description: markdown(description),
                     reference: t['reference'], title: t['subject'],
                     created_at: Time.parse(t['submitted_at']),
                     updated_at: Time.parse(t['updated_at']),
                     email: t['contact_methods.data'],
                     priority: t['priorities.name'],
                     name: t['contacts.name'],
                     status: t['statuses.status_type'],
                     department: t['departments.name'],
                     unread_tickets: unread_tickets}
          case t['departments.name']
          when 'Access Requests'
            params.merge!(visitor_names: [t['contacts.name'], t["custom_field.visitor_names"]].reject(&:blank?).join(', '),
                          date_of_visit: t["custom_field.date_of_visit"],
                          time_of_visit: t["custom_field.time_of_visit"])
          when 'Technical Support', 'Colo Support'
            params.merge!(attachments: attachments(t['reference']))
            params.merge!(more_info: t["custom_field.more_info"])
            params.merge!(:department => "Colo Support") if colo_user
          end
          tickets.push(Ticket.new(params))
        end
      end.each(&:join)
      tickets.sort_by{|t| t.created_at}.reverse
    end

    def departments
      Rails.cache.fetch("stronghold_departments", expires_in: 1.day) do
        dc = SIRPORTLY.brands.select do |b|
          b.name.downcase == SIRPORTLY_BRAND
        end
        dc.present? ? dc.first.departments.reject(&:private).collect(&:name).sort : []
      end
    end

    def priorities
      Rails.cache.fetch("stronghold_priorities", expires_in: 1.day) do
        SIRPORTLY.priorities.collect(&:name)
      end
    end

    def create(ticket)
      user = Authorization.current_user
      colo_user = Authorization.current_organization.colo? && !Authorization.current_organization.cloud?
      if !Authorization.current_organization.known_to_payment_gateway? &&
        ticket.priority.downcase == 'emergency'
        return
      end
      properties = {
        :brand => SIRPORTLY_BRAND,
        :department => ticket.department,
        :status => 'New',
        :priority => ticket.priority,
        :subject => ticket.title,
        :name => ticket.name,
        :email => ticket.email,
        'custom[organization_name]' => Authorization.current_organization.name,
        'custom[company_reference]' => Authorization.current_organization.reporting_code
      }
      case ticket.department
      when "Access Requests"
        properties.merge!({'custom[visitor_names]'   => ticket.visitor_names,
                           'custom[nature_of_visit]' => ticket.nature_of_visit,
                           'custom[date_of_visit]'   => ticket.date_of_visit,
                           'custom[time_of_visit]'   => ticket.time_of_visit})
      when "Technical Support"
        properties.merge!({'custom[more_info]' => ticket.more_info})
        properties.merge!(:department => "Colo Support") if colo_user
      end
      new_ticket = SIRPORTLY.create_ticket(properties)
      update = new_ticket.post_update(:message => ticket.description, :author_name => user.name, :author_email => user.email)
      new_ticket.reference
    end

    def create_comment(comment)
      ticket  = SIRPORTLY.ticket(comment.ticket_reference)
      comment = ticket.post_update(:message => comment.text, :customer => Authorization.current_user.id)
      ""
    end

    def update(params)
      ticket = SIRPORTLY.ticket(params[:id])
      params.delete(:id)
      params[:status] = (params[:status].downcase == 'open' ? 'New' : 'Resolved') if params[:status]

      ticket.update(params)
    end

    def attachments(reference)
      ticket = SIRPORTLY.ticket(reference)
      updates = ticket.updates.collect{|u| u}
      attachments = updates.collect{|u| u.attachments}.flatten.collect{|a| [a['id'], a['name'], a['file_size']]}
      @attachments = attachments.map do |id, name, size|
        {id: id, name: name, url: ExternalLinks.ticket_attachment_path(reference, id, name), size: number_to_human_size(size) }
      end
    end
  end
end
