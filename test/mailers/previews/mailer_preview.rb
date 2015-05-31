class MailerPreview < ActionMailer::Preview
  def signup
    Mailer.signup(Invite.first.id)
  end

  def usage_report
    Mailer.usage_report((Time.now - 7.days).to_s, Time.now.to_s)
  end

  def usage_sanity_failures
    Mailer.usage_sanity_failures(Sanity.check)
  end

  def activation_reminder
    Mailer.activation_reminder('foo@bar.com')
  end

  def reset
    Mailer.reset(Reset.first.id)
  end

  def fraud_check_alert
    Mailer.fraud_check_alert({}, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ')
  end

  def card_reverification_failure
    Mailer.card_reverification_failure(Organization.first)
  end


  def notify_wait_list_entry
    Mailer.notify_wait_list_entry('foo@bar.com')
  end

  def goodbye
    Mailer.goodbye(Organization.first.admin_users)
  end

  def notify_staff_of_signup
    Mailer.notify_staff_of_signup('foo@bar.com')
  end
end