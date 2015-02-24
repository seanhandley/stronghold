class MailerPreview < ActionMailer::Preview
  def signup
    Mailer.signup(Invite.first.id)
  end

  def usage_report
    Mailer.usage_report(Time.now - 7.days, Time.now)
  end
end