module ActionMailer
  class MessageDelivery < Delegator
    def deliver_now_by_api
      send_with_style
      deliver_now
    end

    def deliver_later_by_api
      send_with_style
      deliver_later
    end

    private

    def send_with_style
      options = { with_html_string: true, base_url: 'my.datacentred.io' }
      html = html_part ? html_part.body.decoded : raw_source
      premailer = Premailer.new(html, options)
      plain_text = premailer.to_plain_text
      options.merge! css_string: mail_style.html_safe
      premailer = Premailer.new(html, options)
      html_body = premailer.to_inline_css

      html_part = html_body
      text_part = plain_text
    end

    def mail_style
      File.read(Rails.root.join('app/assets/stylesheets/email.css'))
    end

  end
end
