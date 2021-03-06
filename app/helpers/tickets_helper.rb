module TicketsHelper

  def decorated_tickets(organization=Authorization.current_organization)
    TicketAdapter.all(params[:page], organization).collect do |t|
      TicketDecorator.new(t).decorate
    end
  end

  def department_with_description(department)
    case department
    when 'Access Requests'
      "Access Requests (Book a visit to a datacentre)"
    when 'Accounts & Billing'
      "Accounts & Billing (Payments, invoices etc)"
    when 'Technical Support'
      if current_organization.colo?
        "Technical Support (Issues with DataCentred infrastructure)"
      else
        "Technical Support (Quota changes, OpenStack/API issues etc)"
      end
    else
      department
    end
  end

  def options_for_ticket_departments(departments)
    options_for_select(departments.map{|d| [department_with_description(d), d]})
  end

  def markdown(text)
    begin
      render_options = {
        # will remove from the output HTML tags inputted by user
        filter_html:     true,
        # will insert <br /> tags in paragraphs where are newlines
        # (ignored by default)
        hard_wrap:       true,
        # hash for extra link options, for example 'nofollow'
        link_attributes: { rel: 'nofollow' }
        # more
        # will remove <img> tags from output
        # no_images: true
        # will remove <a> tags from output
        # no_links: true
        # will remove <style> tags from output
        # no_styles: true
        # generate links for only safe protocols
        # safe_links_only: true
        # and more ... (prettify, with_toc_data, xhtml)
      }
      renderer = Redcarpet::Render::HTML.new(render_options)

      extensions = {
        #will parse links without need of enclosing them
        autolink:           true,
        # blocks delimited with 3 ` or ~ will be considered as code block.
        # No need to indent.  You can provide language name too.
        # ```ruby
        # block of code
        # ```
        fenced_code_blocks: true,
        # will ignore standard require for empty lines surrounding HTML blocks
        lax_spacing:        true,
        # will not generate emphasis inside of words, for example no_emph_no
        no_intra_emphasis:  true,
        # will parse strikethrough from ~~, for example: ~~bad~~
        strikethrough:      true,
        # will parse superscript after ^, you can wrap superscript in ()
        superscript:        true
        # will require a space after # in defining headers
        # space_after_headers: true
      }
      Redcarpet::Markdown.new(renderer, extensions).render(text).html_safe
    rescue StandardError => e
      Rails.logger.debug "Bad input received: #{text}"
      return text
    end
  end

end
