class MailerPreview < ActionMailer::Preview
  def signup
    Mailer.signup(Invite.first.id)
  end
end