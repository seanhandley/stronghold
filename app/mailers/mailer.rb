class Mailer < ActionMailer::Base
  add_template_helper(DateTimeHelper)
  default :from => "DataCentred <noreply@datacentred.co.uk>"
  
  def signup(invite_id)
    @invite = Invite.find(invite_id)
    mail(:to => @invite.email, :subject => "Welcome to DataCentred")
  end

  def reset(reset_id)
    @reset = Reset.find(reset_id)
    mail(:to => @reset.email, :subject => "Reset your password")
  end
end