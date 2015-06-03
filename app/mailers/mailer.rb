class Mailer < ActionMailer::Base
  add_template_helper(DateTimeHelper)
  default :from => "DataCentred <noreply@datacentred.co.uk>"
  
  def signup(invite_id)
    @invite = Invite.find(invite_id)
    mail(:to => @invite.email, :subject => "Confirm your account")
  end

  def reset(reset_id)
    @reset = Reset.find(reset_id)
    mail(:to => @reset.email, :subject => "Password reset")
  end

  def usage_report(from, to)
    @from = Time.parse(from)
    @to   = Time.parse(to)
    # Total available platform resources, with % in-use
    @platform_usage_summary = {}
    @organization_data = Reports::UsageReport.new(@from, @to).contents

    mail(:to => "usage@datacentred.co.uk", :subject => "Weekly Platform Usage")
  end

  def usage_sanity_failures(data)
    @data = data
    @keys = ['instances', 'volumes', 'images', 'routers']
    mail(:to => "devops@datacentred.co.uk", :subject => 'Usage Sanity Check Failures')
  end

  def fraud_check_alert(args, report_url)
    @args = args
    @report_url = report_url
    mail(:to => "devops@datacentred.co.uk", :subject => 'Fraud Check Failure')
  end

  def card_reverification_failure(organization)
    @organization = organization
    mail(:to => organization.admin_users.collect(&:email).join(', '), :bcc => "devops@datacentred.co.uk", :subject => "There's a problem with your card")   
  end

  def notify_wait_list_entry(email)
    @email = email
    mail(:to => email, :subject => "We're back!")   
  end

  def goodbye(admins)
    email = admins.collect(&:email).join(', ')
    mail(:to => email, :subject => "Account closed")   
  end

  def activation_reminder(email)
    mail(:to => email, :subject => "Activate your DataCented account")   
  end

  def notify_staff_of_signup(organization)
    customer_signup = organization.customer_signup
    @email = customer_signup.email
    @salesforce_link = "https://eu2.salesforce.com/#{customer_signup.organization.salesforce_id}"
    mail(:to => 'signups@datacentred.co.uk', :subject => "New Signup: #{@email}")   
  end
end