class DeliverhqMailJob < ApplicationJob
  queue_as :default

  def perform(invite)
    mail = Mailer.signup(invite.id)
    # premailer = Premailer::Rails::CustomizedPremailer.new(mail.body.raw_source)
    # message = Deliverhq::send from: [mail.from].flatten.join(","), to: mail.to.join(","), subject: mail.subject,
    #                           html_body: premailer.to_inline_css, plain_body: premailer.to_plain_text
    message = Deliverhq::send from: [mail.from].flatten.join(","), to: mail.to.join(","), subject: mail.subject,
                              html_body: mail.body.decoded, plain_body: mail.body.decoded #, plain_body: premailer.to_plain_text
    invite.update_column :remote_message_id, message.id
  end
end