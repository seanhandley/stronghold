module ActionMailer
  class MessageDelivery < Delegator
    def deliver_now_by_api
      send_with_style(self).deliver_now
    end

    def deliver_later_by_api
      send_with_style(self).deliver_later
    end

    private

    def send_with_style(mail)
      options = { with_html_string: true, base_url: 'my.datacentred.io' }
      html = mail.html_part ? mail.html_part.body.decoded : mail.body.raw_source
      premailer = Premailer.new(html, options)
      plain_text = premailer.to_plain_text
      options.merge! css_string: mail_style.html_safe
      premailer = Premailer.new(html, options)
      html_body = premailer.to_inline_css

      mail.instance_variable_set '@text_part'.to_sym, nil
      mail.instance_variable_set '@html_part'.to_sym, nil

      mail.text_part = plain_text
      mail.html_part = html_body
      mail
    end

    def mail_style
      File.read(Rails.root.join('app/assets/stylesheets/email.css'))
    end

  end
end
