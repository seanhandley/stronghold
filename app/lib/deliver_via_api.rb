module ActionMailer
  class MessageDelivery < Delegator
    def deliver_now_by_api
      Deliverhq::send mail_attributes
    end

    def deliver_later_by_api
      DeliverMailByApiJob.perform_later mail_attributes
    end

    private

    def mail_attributes
      options = { with_html_string: true, base_url: 'my.datacentred.io' }
      premailer = Premailer.new(body.raw_source, options)
      plain_text = premailer.to_plain_text
      options.merge! css_string: mail_style.html_safe
      premailer = Premailer.new(body.raw_source, options)
      {
        from: [from].flatten.join(","),
        to: to.join(","),
        subject: subject,
        html_body: premailer.to_inline_css, plain_body: plain_text
      }
    end

    def mail_style
      File.read(Rails.root.join('app/assets/stylesheets/email.css'))
    end
  end
end
