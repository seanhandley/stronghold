class Mailer < ActionMailer::Base
  add_template_helper(DateTimeHelper)
  add_template_helper(AbbreviationHelper)
  add_template_helper(UsageAlertHelper)
  include CsvHelper
  include UsageAlertHelper

  default :from => "DataCentred <noreply@datacentred.io>"

  def signup(invite_id)
    @invite = Invite.find(invite_id)
    mail(:to => @invite.email, :subject => "Confirm your account", :skip_premailer => true)
  end

  def reset(reset_id)
    @reset = Reset.find(reset_id)
    mail(:to => @reset.email, :subject => "Password reset", :skip_premailer => true)
  end

  def usage_report(from, to, data)
    @from = Time.parse(from)
    @to   = Time.parse(to)
    @organization_data = data
    @week_beginning = @from.beginning_of_week.to_date.strftime("%A #{@from.day.ordinalize} %B %Y")
    @csv_string = build_usage_report_csv(data)
    attachments["weekly_usage_#{@week_beginning.parameterize}.csv"] = @csv_string
    mail(:to => "usage@datacentred.co.uk", :subject => "Weekly Platform Usage", :skip_premailer => true)
  end

  def usage_sanity_failures(data)
    @data = data
    @keys = ['instances', 'volumes', 'images', 'routers']
    mail(:to => "devops@datacentred.co.uk", :subject => 'Usage Sanity Check Failures', :skip_premailer => true)
  end

  def fraud_check_alert(customer_signup, fraud_check, recipient="fraud@datacentred.co.uk")
    @customer_signup = customer_signup
    @fraud_check     = fraud_check
    @reasons         = fraud_check.suspicious?
    mail(:to => recipient, :subject => "Potential Fraud: #{customer_signup.organization_name}", :skip_premailer => true)
  end

  def card_reverification_failure(organization)
    @organization = organization
    mail(:to => organization.admin_users.collect(&:email).join(', '), :bcc => "fraud@datacentred.co.uk", :subject => "There's a problem with your card", :skip_premailer => true)
  end

  def notify_wait_list_entry(email)
    @email = email
    mail(:to => email, :subject => "We're back!", :skip_premailer => true)
  end

  def goodbye(admins)
    email = admins.collect(&:email).join(', ')
    mail(:to => email, :subject => "Account closed", :skip_premailer => true)
  end

  def activation_reminder(email)
    mail(:to => email, :subject => "Activate your DataCented account")
  end

  def notify_staff_of_signup(organization)
    @organization = organization
    @salesforce_link = "https://eu2.salesforce.com/#{@organization.salesforce_id}"
    mail(:to => 'signups@datacentred.co.uk', :subject => "New Signup: #{@organization.name}", :skip_premailer => true)
  end

  def review_mode_alert(organization)
    mail(:to => organization.admin_users.collect(&:email).join(', '),
         :subject => "Account Review: Please respond ASAP", :skip_premailer => true)
  end

  def review_mode_successful(organization)
    mail(:to => organization.admin_users.collect(&:email).join(', '),
         :subject => "Account Review Completed", :skip_premailer => true)
  end

  def quota_changed(organization)
    mail(:to => organization.admin_users.collect(&:email).join(', '),
         :subject => "Your account limits have changed", :skip_premailer => true)
  end

  def quota_limits_alert(organization_id)
    organization = Organization.find(organization_id)
    mail(:to => organization.admin_users.collect(&:email).join(', '),
         :subject => "You are reaching your quota limit", :skip_premailer => true)
  end
end
