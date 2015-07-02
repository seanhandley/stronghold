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
    Mailer.notify_staff_of_signup(CustomerSignup.first)
  end

  def fraud_check_alert
    Mailer.fraud_check_alert(CustomerSignup.last, fc)
  end

  def review_mode_alert
    Mailer.review_mode_alert(CustomerSignup.last)
  end

  def review_mode_successful
    Mailer.review_mode_successful(Organization.first)
  end

  private

  def fc
    Marshal::load("\x04\bo:\x0FFraudCheck\x06:\x15@customer_signupo:\x13CustomerSignup\x11:\x10@attributeso:\x1FActiveRecord::AttributeSet\x06;\bo:$ActiveRecord::LazyAttributeHash\n:\v@types}\x15I\"\aid\x06:\x06ETo: ActiveRecord::Type::Integer\t:\x0F@precision0:\v@scale0:\v@limiti\t:\v@rangeo:\nRange\b:\texclT:\nbeginl-\a\x00\x00\x00\x80:\bendl+\a\x00\x00\x00\x80I\"\tuuid\x06;\fTo:HActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::MysqlString\b;\x0E0;\x0F0;\x10i\x01\xFFI\"\nemail\x06;\fT@\x10I\"\x16organization_name\x06;\fT@\x10I\"\x17stripe_customer_id\x06;\fT@\x10I\"\x0Fip_address\x06;\fT@\x10I\"\x0Fcreated_at\x06;\fTU:JActiveRecord::AttributeMethods::TimeZoneConversion::TimeZoneConverter[\t:\v__v2__[\x00[\x00o:!ActiveRecord::Type::DateTime\b;\x0E0;\x0F0;\x100I\"\x0Fupdated_at\x06;\fTU;\x17[\t;\x18[\x00[\x00@\x1AI\"\x12reminder_sent\x06;\fTo: ActiveRecord::Type::Boolean\b;\x0E0;\x0F0;\x10i\x06I\"\x12discount_code\x06;\fT@\x10I\"\freal_ip\x06;\fT@\x10I\"\x11forwarded_ip\x06;\fT@\x10I\"\x0Edevice_id\x06;\fT@\x10I\"\x18activation_attempts\x06;\fT@\vI\"\x0Fuser_agent\x06;\fT@\x10I\"\x14accept_language\x06;\fT@\x10o:\x1EActiveRecord::Type::Value\b;\x0E0;\x0F0;\x100:\f@values{\x15I\"\aid\x06;\fTi~I\"\tuuid\x06;\fTI\"%d2143aca3cdb2291bb94c5e3da6ff632\x06;\fTI\"\nemail\x06;\fTI\"\x19spiroadams@gmail.com\x06;\fTI\"\x16organization_name\x06;\fT0I\"\x17stripe_customer_id\x06;\fT0I\"\x0Fip_address\x06;\fTI\"\x1187.254.80.79\x06;\fTI\"\x0Fcreated_at\x06;\fTIu:\tTime\r\v\xD7\x1C\xC0\x00\x00@\x10\x06:\tzone\"\bUTCI\"\x0Fupdated_at\x06;\fTIu;\x1D\r\f\xD7\x1C\xC0\x00\x00@\x1D\x06;\x1E\"\bUTCI\"\x12reminder_sent\x06;\fTi\x06I\"\x12discount_code\x06;\fT0I\"\freal_ip\x06;\fTI\"\x1187.254.80.79\x06;\fTI\"\x11forwarded_ip\x06;\fTI\"\x1187.254.80.79\x06;\fTI\"\x0Edevice_id\x06;\fTI\"%baae14c31124e3b8885033e005f77960\x06;\fTI\"\x18activation_attempts\x06;\fTi\x00I\"\x0Fuser_agent\x06;\fTI\"uMozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2440.0 Safari/537.36\x06;\fTI\"\x14accept_language\x06;\fTI\"\x13en-US,en;q=0.8\x06;\fT:\x16@additional_types{\x00:\x12@materializedF:\x13@delegate_hash{\x15I\"\aid\x06;\fTo:*ActiveRecord::Attribute::FromDatabase\t:\n@nameI\"\aid\x06;\fT:\x1C@value_before_type_casti~:\n@type@\v:\v@valuei~I\"\tuuid\x06;\fTo;\"\t;#I\"\tuuid\x06;\fT;$@-;%@\x10;&I\"%d2143aca3cdb2291bb94c5e3da6ff632\x06;\fTI\"\nemail\x06;\fTo;\"\t;#I\"\nemail\x06;\fT;$@/;%@\x10;&I\"\x19spiroadams@gmail.com\x06;\fTI\"\x16organization_name\x06;\fTo;\"\t;#I\"\x16organization_name\x06;\fT;$0;%@\x10;&0I\"\x17stripe_customer_id\x06;\fTo;\"\t;#I\"\x17stripe_customer_id\x06;\fT;$0;%@\x10;&0I\"\x0Fip_address\x06;\fTo;\"\t;#I\"\x0Fip_address\x06;\fT;$@3;%@\x10;&I\"\x1187.254.80.79\x06;\fTI\"\x0Fcreated_at\x06;\fTo;\"\t;#I\"\x0Fcreated_at\x06;\fT;$@6;%@\x16;&U: ActiveSupport::TimeWithZone[\b@6I\"\vLondon\x06;\fTu;\x1D\r\f\xD7\x1C\xC0\x00\x00@\x10I\"\x0Fupdated_at\x06;\fTo;\"\t;#I\"\x0Fupdated_at\x06;\fT;$@9;%@\x1C;&U;'[\b@9@cu;\x1D\r\r\xD7\x1C\xC0\x00\x00@\x1DI\"\x12reminder_sent\x06;\fTo;\"\t;#I\"\x12reminder_sent\x06;\fT;$i\x06;%@!;&TI\"\x12discount_code\x06;\fTo;\"\t;#I\"\x12discount_code\x06;\fT;$0;%@\x10;&0I\"\freal_ip\x06;\fTo;\"\t;#I\"\freal_ip\x06;\fT;$@=;%@\x10;&I\"\x1187.254.80.79\x06;\fTI\"\x11forwarded_ip\x06;\fTo;\"\t;#I\"\x11forwarded_ip\x06;\fT;$@?;%@\x10;&I\"\x1187.254.80.79\x06;\fTI\"\x0Edevice_id\x06;\fTo;\"\t;#I\"\x0Edevice_id\x06;\fT;$@A;%@\x10;&I\"%baae14c31124e3b8885033e005f77960\x06;\fTI\"\x18activation_attempts\x06;\fTo;\"\t;#I\"\x18activation_attempts\x06;\fT;$i\x00;%@\v;&i\x00I\"\x0Fuser_agent\x06;\fTo;\"\t;#I\"\x0Fuser_agent\x06;\fT;$@D;%@\x10;&I\"uMozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2440.0 Safari/537.36\x06;\fTI\"\x14accept_language\x06;\fTo;\"\t;#I\"\x14accept_language\x06;\fT;$@F;%@\x10;&I\"\x13en-US,en;q=0.8\x06;\fT:\x17@aggregation_cache{\x00:\x17@association_cache{\x00:\x0E@readonlyF:\x0F@destroyedF:\x1C@marked_for_destructionF:\x1E@destroyed_by_association0:\x10@new_recordF:\t@txn0:\x1E@_start_transaction_state{\x00:\x17@transaction_state0:\x14@reflects_state[\x06F")
  end
end