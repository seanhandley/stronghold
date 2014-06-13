class Mailer < ActionMailer::Base
  add_template_helper(DateTimeHelper)
  default :from => "DataCentred Ltd <noreply@datacentred.co.uk>"
  
  def signup(invite_id)
    @invite = Invite.find(invite_id)
    mail(:to => @invite.email, :subject => "Welcome to DataCentred")
  end
end