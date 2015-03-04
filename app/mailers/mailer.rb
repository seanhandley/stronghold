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
    mail(:to => "devops@datacentred.co.uk", :subject => 'Usage Sanity Check Failures')
  end
end