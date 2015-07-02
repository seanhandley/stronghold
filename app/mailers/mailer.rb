class Mailer < ActionMailer::Base
  add_template_helper(DateTimeHelper)
  add_template_helper(AbbreviationHelper)

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

  def fraud_check_alert(customer_signup, fraud_check, recipient="fraud@datacentred.co.uk")
    @customer_signup = customer_signup
    @fraud_check = fraud_check
    mail(:to => recipient, :subject => "Potential Fraud: #{customer_signup.organization_name}")
  end

  def card_reverification_failure(organization)
    @organization = organization
    mail(:to => organization.admin_users.collect(&:email).join(', '), :bcc => "fraud@datacentred.co.uk", :subject => "There's a problem with your card")   
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
    @organization = organization
    @salesforce_link = "https://eu2.salesforce.com/#{@organization.salesforce_id}"
    mail(:to => 'signups@datacentred.co.uk', :subject => "New Signup: #{@organization.name}")   
  end

  def review_mode_alert(customer_signup)
    mail(:to => customer_signup.organization.admin_users.collect(&:email).join(', '),
         :subject => "Account Review: Please respond ASAP")
  end

  def review_mode_successful(organization)
    mail(:to => organization.admin_users.collect(&:email).join(', '),
         :subject => "Account Review Completed")
  end
end