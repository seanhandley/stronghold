require 'test_helper'
require_relative '../../mailers/previews/mailer_preview'

class MailerTest < ActionMailer::TestCase
  def test_signup
    @invite = Invite.make!

    email = Mailer.signup(@invite.id).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert email.from.include?("noreply@datacentred.io")
    assert_equal [@invite.email], email.to
    assert_equal 'Confirm your account', email.subject
    assert email.body.parts[1].to_s.include?(@invite.token), 'mail body contains invite token'
  end

  def test_reset
    @reset = Reset.make!

    email = Mailer.reset(@reset.id).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert email.from.include?("noreply@datacentred.io")
    assert_equal [@reset.email], email.to
    assert_equal 'Password reset', email.subject
    assert email.body.parts[1].to_s.include?(@reset.token), 'mail body contains reset token'
  end

  def test_usage_report
    from = (Time.zone.now - 1.day).beginning_of_week
    to = (Time.zone.now - 1.day).end_of_week
    data = usage_report_data
    email = Mailer.usage_report(from.to_s, to.to_s, data).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert email.from.include?("noreply@datacentred.io")
    assert_equal ['usage@datacentred.co.uk'], email.to
    assert_equal 'Weekly Platform Usage', email.subject

    assert_equal 1, email.attachments.count
  end

  def test_usage_sanity_failures
    data = usage_sanity_data
    email = Mailer.usage_sanity_failures(data)
    # This email isn't sent via SMTP, but as HTML via a Slack notification
    text = "* test - 1234 - #{Project.first.organization.name}"
    assert email.body.parts[0].to_s.include?(text), 'message body contains details'
  end

  def test_fraud_check_alert
    @cs = CustomerSignup.make!
    Organization.make!(customer_signup: @cs)

    VCR.use_cassette('fraud_check') do
      Stripe::Customer.stub(:retrieve, nil) do
        @fraud_check = MailerPreview.new.fc
        @email = Mailer.fraud_check_alert(@cs, @fraud_check).deliver_now
      end
    end

    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal ['fraud@datacentred.co.uk'], @email.to
    assert_equal "Potential Fraud: #{@cs.organization_name}", @email.subject

    assert @email.body.parts[1].to_s.include?('MaxMind Risk Score:</strong> 89.29 (out of 100)')
  end

  def test_card_reverification_failure
    @organization = Organization.make!
    @user = User.make!(organization: @organization)
    @organization.stub(:admin_users, [@user]) do
      @email = Mailer.card_reverification_failure(@organization).deliver_now
    end
    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal [@user.email], @email.to
    assert_equal ['fraud@datacentred.co.uk'], @email.bcc
    assert_equal "There's a problem with your card", @email.subject
  end

  def test_notify_wait_list_entry
    @email = Mailer.notify_wait_list_entry("foo@bar.com").deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal ["foo@bar.com"], @email.to
    assert_equal "We're back!", @email.subject
  end

  def test_goodbye
    @admins = [User.make!]
    @email = Mailer.goodbye(@admins).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal @admins.map(&:email), @email.to
    assert_equal "Account closed", @email.subject
  end

  def test_activation_reminder
    @email = Mailer.activation_reminder("foo@bar.com").deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal ["foo@bar.com"], @email.to
    assert_equal "Activate your DataCented account", @email.subject
  end

  def test_notify_staff_of_signup
    @organization = Organization.make!
    @email = Mailer.notify_staff_of_signup(@organization).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal ["signups@datacentred.co.uk"], @email.to
    assert_equal "New Signup: #{@organization.name}", @email.subject
  end

  def test_review_mode_alert
    @cs = CustomerSignup.make!
    @user = User.make!
    @user.organization.stub(:admin_users, [@user]) do
      @cs.stub(:organization, @user.organization) do
        @email = Mailer.review_mode_alert(@cs.organization).deliver_now
      end
    end

    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal [@user.email], @email.to
    assert_equal "Account Review: Please respond ASAP", @email.subject
  end

  def test_review_mode_successful
    @user = User.make!
    @user.organization.stub(:admin_users, [@user]) do
      @email = Mailer.review_mode_successful(@user.organization).deliver_now
    end

    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal [@user.email], @email.to
    assert_equal "Account Review Completed", @email.subject
  end

  def test_quota_changed
    @user = User.make!
    @user.organization.stub(:admin_users, [@user]) do
      @email = Mailer.quota_changed(@user.organization).deliver_now
    end

    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal [@user.email], @email.to
    assert_equal "Your account limits have changed", @email.subject
  end

  def test_quota_limits_alert
    @organization = Organization.make!
    @role = Role.make! organization: @organization, power_user: true
    @user = User.make! organization: @organization
    @role.users << @user
    @email = Mailer.quota_limits_alert(@organization.id).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?

    assert @email.from.include?("noreply@datacentred.io")
    assert_equal [@user.email], @email.to
    assert_equal "You are reaching your quota limit", @email.subject
  end

  def teardown
    DatabaseCleaner.clean
  end

  private

  def usage_report_data
    [{:name=>"DataCentred", :contacts=>[], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>false, :spend=>0}, {:name=>"test@test.com", :contacts=>[], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>false, :spend=>0}, {:name=>"test@test.com", :contacts=>[], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>false, :spend=>0}, {:name=>"foo@bar.com", :contacts=>[], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>false, :spend=>0}, {:name=>"foo@bar.com", :contacts=>[], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>false, :spend=>0}, {:name=>"DataCentred Development", :contacts=>["sean.handley@datacentred.co.uk", "foo@bar.com"], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>true, :spend=>0}, {:name=>"sean.handley+test40@gmail.com", :contacts=>["sean.handley+test40@gmail.com"], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>true, :spend=>0}, {:name=>"sean.handley+freeze@gmail.com", :contacts=>["sean.handley+freeze@gmail.com"], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>true, :spend=>0}, {:name=>"test@test.com", :contacts=>[], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>false, :spend=>0}, {:name=>"foo@bazbar.com", :contacts=>["foo@bazbar.com"], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>true, :spend=>0}, {:name=>"sean.handley+foo@gmail.com", :contacts=>["sean.handley+foo@gmail.com"], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>true, :spend=>0}, {:name=>"sean.handley+barfs@gmail.com", :contacts=>[], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>false, :spend=>0}, {:name=>"sean.handley+dsf@gmail.com", :contacts=>["sean.handley+dsf@gmail.com"], :vcpu_hours=>0.0, :ram_tb_hours=>0.0, :openstack_tb_hours=>0, :ceph_tb_hours=>0.0, :load_balancer_hours=>0.0, :vpn_connection_hours=>0.0, :paying=>true, :spend=>0}]
  end

  def usage_sanity_data
    {missing_instances: {'1234' => {name: 'test', project_id: Project.make!.uuid}}, missing_volumes: {}, missing_images: {}, missing_routers: {}, new_instances: {}, sane: false}
  end
end
