require 'sirportly'

class TicketAdapter
  extend TicketsHelper
  extend ActionView::Helpers::TextHelper

  class << self
    def all(page=1, organization=Authorization.current_user.organization)
      tickets = []
      limit = 15
      page = page.to_i
      offset = page > 1 ? ((page - 1) * limit) : nil
      limit = [offset, limit].compact
      columns = %w{reference subject submitted_at updated_at
                   contact_methods.data priorities.name
                   contacts.name statuses.status_type departments.name
                   custom_field.visitor_names
                   custom_field.date_of_visit
                   custom_field.time_of_visit
                  }
      spql = "SELECT #{columns.join(',')} FROM tickets WHERE contacts.company = \"#{organization.reference}\" GROUP BY submitted_at ORDER BY submitted_at DESC LIMIT #{limit.join(',')}"
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
                     department: t['departments.name']}
          case t['departments.name']
          when 'Access Requests'
            params.merge!(visitor_names: [t['contacts.name'], t["custom_field.visitor_names"]].reject(&:blank?).join(', '),
                          date_of_visit: t["custom_field.date_of_visit"],
                          time_of_visit: t["custom_field.time_of_visit"])
          when 'Support'
            params.merge!(more_info: t["custom_field.more_info"])
            if Authorization.current_user.organization.colo?
              params.merge!(:department => "Colo Support")
            end
          end
          tickets.push(Ticket.new(params))
        end
      end.each(&:join)
      tickets.sort_by{|t| t.created_at}.reverse
    end

    def departments
      Rails.cache.fetch("stronghold_departments", expires_in: 1.day) do
        dc = SIRPORTLY.brands.select do |b|
          b.name.downcase == SIRPORTLY_ARGS['brand'].downcase
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
      if !Authorization.current_user.organization.known_to_payment_gateway? &&
        ticket.priority.downcase == 'emergency'
        return
      end
      properties = {
        :brand => SIRPORTLY_ARGS['brand'],
        :department => ticket.department,
        :status => 'New',
        :priority => ticket.priority,
        :subject => ticket.title,
        :name => ticket.name,
        :email => ticket.email,
        'custom[organization_name]' => Authorization.current_user.organization.name
      }
      case ticket.department
      when "Access Requests"
        properties.merge!({'custom[visitor_names]'   => ticket.visitor_names,
                           'custom[nature_of_visit]' => ticket.nature_of_visit,
                           'custom[date_of_visit]'   => ticket.date_of_visit,
                           'custom[time_of_visit]'   => ticket.time_of_visit})
      when "Support"
        properties.merge!({'custom[more_info]' => ticket.more_info})
        if Authorization.current_user.organization.colo?
          properties.merge!(:department => "Colo Support")
        end
      end
      new_ticket = SIRPORTLY.create_ticket(properties)
      update = new_ticket.post_update(:message => ticket.description, :author_name => Authorization.current_user.name, :author_email => Authorization.current_user.email)
      new_ticket.reference
    end

    def create_comment(comment)
      ticket  = SIRPORTLY.ticket(comment.ticket_reference)
      comment = ticket.post_update(:message => comment.text, :customer => Authorization.current_user.unique_id)
      ""
    end

    def update(params)
      ticket = SIRPORTLY.ticket(params[:id])
      params.delete(:id)
      params[:status] = (params[:status].downcase == 'open' ? 'New' : 'Resolved') if params[:status]

      ticket.update(params)
    end
  end
end
