class Mailer < ActionMailer::Base
  default :from => "DataCentred Ltd <noreply@datacentred.co.uk>"
  
  def signup(signup_id)
    @signup = Signup.find(signup_id)
    mail(:to => @signup.email, :subject => "DataCentred: Please set up your account")
  end
end